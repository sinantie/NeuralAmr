local beam = require 's2sa.beam'

function main()
  beam.init(arg)
  local opt = beam.getOptions()
  
  if opt.interactive_mode == 0 then
		assert(path.exists(opt.src_file), 'src_file does not exist')
		local sent_id = 0
		file_size = 0
		for _ in io.lines(opt.src_file) do
			file_size = file_size + 1
		end

		local file = io.open(opt.src_file, "r")
		local out_file = io.open(opt.output_file,'w')
		for line in file:lines() do
			sent_id = sent_id + 1
			xlua.progress(sent_id, file_size)
			result, nbests = beam.search(line, nil)
			out_file:write(result .. '\n')

			for n = 1, #nbests do
				out_file:write(nbests[n] .. '\n')
			end
		end

		print(string.format("PRED AVG SCORE: %.4f, PRED PPL: %.4f", pred_score_total / pred_words_total,
			math.exp(-pred_score_total/pred_words_total)))
		if opt.score_gold == 1 then
			print(string.format("GOLD AVG SCORE: %.4f, GOLD PPL: %.4f",
				gold_score_total / gold_words_total,
				math.exp(-gold_score_total/gold_words_total)))
		end
		out_file:close()
	else
		local typeOfAmr = opt.input_type
		print('Input AMR in ' .. typeOfAmr .. ' format [Type q to exit]:')
-- 		local f = io.open(opt.src_file, "r")
-- 		local input = f:read()
-- 		f:close()
		while true do
			local input = io.read()
			if input == 'q' then
				break
			end
			local flatInput = stringx.replace(input, '\n', ' ')
			flatInput = stringx.replace(flatInput, '\"', '\\"')
			-- anonymize and grab alignments
			f = io.popen('./anonDeAnon_java.sh ' .. typeOfAmr .. ' \"' .. flatInput .. '\"', rw)
			local anonymizedInput, alignments = unpack(stringx.split(f:read('*all'), '#'))
			alignments = stringx.replace(alignments, '\n', '')
			if opt.verbose > 0 then
				print('anonymized: ' .. anonymizedInput)
				print('alignments: ' .. alignments)
			end
			f:close()
			if anonymizedInput == 'FAILED_TO_PARSE' then
				if alignments == 'Failed to parse.' then
					print('Failed to parse.')
				else
					print('Failed to parse. ' .. alignments .. '\n')
				end
			else
				local pred, pred_score, attn, pred_out = predSingleSentence(anonymizedInput)
				pred_out = stringx.replace(pred_out, '\"', '\\"')
				if opt.verbose > 0 then
					print('predicted (anonymized): ' .. pred_out)
				end
				-- deAnonymize
				if alignments == '\n' then
					f = io.popen('./anonDeAnon_java.sh deAnonymize \"' .. pred_out .. '\"', rw)
				else
					f = io.popen('./anonDeAnon_java.sh deAnonymize \"' .. pred_out .. '#' .. alignments .. '\"', rw)
				end
				local deAnonymized = f:read('*all')
				deAnonymized = stringx.replace(deAnonymized, '\n', '')
				f:close()
				print(deAnonymized)
			end
		end
	end

end

main()
