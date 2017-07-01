# Neural AMR

[Torch](http://torch.ch) implementation of sequence-to-sequence models for AMR parsing and generation based on the [Harvard NLP](https://github.com/sinantie/NeuralAmr/edit/master/README.md) framework. We provide the code for pre-processing, anonymizing, de-anonymizing, training and predicting from and to AMR. We are also including pre-trained models on 20M sentences from Gigaword and fine-tuned on the AMR [LDC2015E86: DEFT Phase 2 AMR Annotation R1 Corpus](https://catalog.ldc.upenn.edu/LDC2015E86). You can find all the details in the following paper:

- [Neural AMR: Sequence-to-Sequence Models for Parsing and Generation](https://arxiv.org/abs/1704.08381). (Ioannis Konstas, Srinivasan Iyer, Mark Yatskar, Yejin Choi, Luke Zettlemoyer. ACL 2017)

## Requirements

The pre-trained models only run on *GPUs*, so you will need to have the following installed:

- Latest [NVIDIA driver](http://www.nvidia.com/Download/index.aspx)
- [CUDA 8 Toolkit](https://developer.nvidia.com/cuda-toolkit)
- [cuDNN](https://developer.nvidia.com/cudnn) (The NVIDIA CUDA Deep Neural Network library)
- [Torch](http://torch.ch/docs/getting-started.html)

## Installation

- Install the following packages for Torch using `luarocks`:
```
nn nngraph cutorch cunn cudnn
```
- Install the Deepmind version of `torch-hdf5` from [here](https://github.com/deepmind/torch-hdf5/blob/master/doc/usage.md).

*(Only for training models)* 

- Install `cudnn.torch` from [here](https://github.com/soumith/cudnn.torch).
- Install the following packages for Python 2.7: 
```
pip install numpy h5py
```

*(Only for downloading the pretrained models)*

- Download and unzip the models from [here](https://drive.google.com/file/d/0B0e2gHbz7CcIc0p1SjRhLVR2bTA/view?usp=sharing)

- Export the cuDNN library path (you can add it to your .bashrc or .profile):
```
export CUDNN_PATH="path_to_cudnn/lib64/libcudnn.so"
```

- Or instead of the previous step you can copy the cuDNN library files into /usr/local/cuda/lib64/ or to the corresponding folders in the CUDA directory.

## Quickstart (AMR Generation)
You can generate text from AMR graphs using our pre-trained model on 20M sentences from Gigaword, in two different ways:
- By running an interactive tool that reads input from `stdin`:
```
./generate_amr_single.sh [stripped|full|anonymized]
```

- By running the prediction on a single file, which contains an AMR graph per line:
```
./generate_amr.sh input_file [stripped|full|anonymized]
```

You can optionally provide an argument that tells the system to accept either `full` AMR as described in the [annotation guidelines](https://github.com/amrisi/amr-guidelines/blob/master/amr.md), or a `stripped` version, which removes variables, senses, parentheses from leaves, and assumes a simpler markup for Named Entities, date mentions, and numbers. You can also provide the input in `anonymized` format, i.e., similar to `stripped` but with Named Entities, date mentions, and numbers anonymized.

An example using the `full` format:
```
(h / hold-04 :ARG0 (p2 / person :ARG0-of (h2 / have-org-role-91 :ARG1 (c2 / country :name (n3 / name :op1 "United" :op2 "States")) :ARG2 (o / official)))  :ARG1 (m / meet-03 :ARG0 (p / person  :ARG1-of (e / expert-01) :ARG2-of (g / group-01))) :time (d2 / date-entity :year 2002 :month 1) :location (c / city  :name (n / name :op1 "New" :op2 "York")))
```

The same example using the `stripped` format:
```
hold :ARG0 ( person :ARG0-of ( have-org-role :ARG1 (country :name "United States") :ARG2 official)) :ARG1 (meet :ARG0 (person  :ARG1-of expert :ARG2-of  group)) :time (date-entity :year 2002 :month 1) :location (city :name "New York" )
```

The same example using the `anonymized` format:
```
hold :ARG0 ( person :ARG0-of ( have-org-role :ARG1 location_name_0 :ARG2 official ) ) :ARG1 ( meet :ARG0 ( person :ARG1-of expert :ARG2-of group ) ) :time ( date-entity year_date-entity_0 month_date-entity_0 ) :location location_name_1
```

For full details and more examples, see [here](). 

## Details

### Generation Options (generate_amr.sh, generate_amr_single.sh)
- `interactive_mode [0,1]`: Set `0` for generating from a file, or `1` to generate from `stdin`.
- `model [str]`: The path to the trained model.
- `input_type [stripped|full]`: Set `full` for standard AMR graph input, or `stripped` which expects AMR graphs with no variables, senses, parentheses from leaves, and assumes a simpler markup for Named Entities (for more details and examples, see [here]()).
- `src_file [str]`: The path to the input file that contains AMR graphs, one per line.
- `gpuid [int]`: The GPU id number.
- `src_dict, targ_dict [str]`: Path to source and target dictionaries. These are usually generated during preprocessing of the corpus. ==Note==: `src_dict` and `targ_dict` paths need to be reversed when generating text or parsing to AMR.
- `beam [int]`: The beam size of the decoder (default is 5).
- `replace_unk [0,1]`: Replace unknown words with either the input token that has the highest attention weight, or the word that maps to the input token as provided in `srctarg_dict`.
- `srctarg_dict [str]`: Path to source-target dictionary to replace unknown tokens. Each line should be a source token and its corresponding target token, separated by `|||` (see `resources/training-amr-nl-alignments.txt`).
- `max_sent_l [str]`: Maximum sentence length (default is 507, i.e., the longest input AMR graph in number of tokens from the dev set). If any of the sequences in `src_file` are longer than this it will error out.

