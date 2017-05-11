local beam = require 's2sa.beam'

function main()
  beam.init(arg)
  local opt = beam.getOptions()
	local typeOfAmr = opt.input_type
  if opt.interactive_mode == 0 then
		assert(path.exists(opt.src_file), 'src_file does not exist')
		local sent_id = 0
		file_size = 0
		for _ in io.lines(opt.src_file) do
			file_size = file_size + 1
		end
		-- produce anonymized version of AMR file and the corresponding alignments in two separate files
		anonymizeFile(typeOfAmr, opt.src_file)
		local file = io.open(opt.src_file .. '.anonymized', "r")
		local out_file = io.open(opt.output_file .. '.pred.anonymized','w')
		for line in file:lines() do
			sent_id = sent_id + 1
			xlua.progress(sent_id, file_size)
			out_file:write(predict('anonymized', line, opt.verbose) .. '\n')
		end
		out_file:close()
		file:close()
		-- deAnonymize predictions using alignments
		deAnonymizeFile(opt.src_file)
	else
		print('Input AMR in ' .. typeOfAmr .. ' format [Type q to exit]:')
		while true do
			local input = io.read()
			if input == 'q' then
				break
			end
			print(predict(typeOfAmr, input, opt.verbose))
		end
	end
end

function predict(typeOfAmr, input, verbose)
	if typeOfAmr == 'anonymized' then
			local pred, pred_score, attn, pred_out = predSingleSentence(input)
			return pred_out
	else
			-- clean
			input = clean(input)
			-- anonymize
      local result, anonymizedInput, alignments = anonymize(typeOfAmr, input, verbose)
      if not result then
      	return anonymizedInput -- error message
      else
      	-- predict
				local pred, pred_score, attn, pred_out = predSingleSentence(anonymizedInput)
				pred_out = stringx.replace(pred_out, '\"', '\\"')
				if verbose > 0 then
					print('predicted (anonymized): ' .. pred_out)
				end
				-- deAnonymize
		    return deAnonymize(pred_out, alignments)
			end
	end
end

function clean(input)
	local flatInput = stringx.replace(input, '\n', ' ')
	flatInput = stringx.replace(flatInput, '\"', '\\"')
	return flatInput
end

function anonymizeFile(typeOfAmr, path)
	local f = io.popen('./anonDeAnon_java.sh ' .. typeOfAmr .. ' true \"' .. path .. '\"', w)
	f:close()
end

function anonymize(typeOfAmr, input, verbose)
	-- anonymize and grab alignments
	local f = io.popen('./anonDeAnon_java.sh ' .. typeOfAmr .. ' false \"' .. input .. '\"', rw)
	local anonymizedInput, alignments = unpack(stringx.split(f:read('*all'), '#'))
	alignments = stringx.replace(alignments, '\n', '')
	if verbose > 0 then
		print('anonymized: ' .. anonymizedInput)
		print('alignments: ' .. alignments)
	end
	f:close()
	if anonymizedInput == 'FAILED_TO_PARSE' then
		if alignments == 'Failed to parse.' then
			return false, 'Failed to parse.', ""
		else
			return false, 'Failed to parse. ' .. alignments, ""
		end
	else
		return true, anonymizedInput, alignments
	end
end

function deAnonymizeFile(path)
	local f = io.popen('./anonDeAnon_java.sh deAnonymize true \"' .. path .. '\"', w)
	f:close()
end

function deAnonymize(pred_out, alignments)
	local f
	if alignments == '\n' then
		f = io.popen('./anonDeAnon_java.sh deAnonymize false \"' .. pred_out .. '\"', rw)
	else
		f = io.popen('./anonDeAnon_java.sh deAnonymize false \"' .. pred_out .. '#' .. alignments .. '\"', rw)
	end
	local deAnonymized = f:read('*all')
	deAnonymized = stringx.replace(deAnonymized, '\n', '')
	f:close()
	return deAnonymized
end

main()
