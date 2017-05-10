# Neural AMR

[Torch](http://torch.ch) implementation of sequence-to-sequence models for AMR parsing and generation based on the [Harvard NLP](https://github.com/sinantie/NeuralAmr/edit/master/README.md) framework. We provide the code for pre-processing, anonymizing, de-anonymizing, training and predicting from and to AMR. We are also including pre-trained models on 20M sentences from Gigaword and fine-tuned on the AMR [LDC2015E86: DEFT Phase 2 AMR Annotation R1 Corpus](https://catalog.ldc.upenn.edu/LDC2015E86). You can find all the details in the following paper:

- [Neural AMR: Sequence-to-Sequence Models for Parsing and Generation](https://arxiv.org/abs/1704.08381). (Ioannis Konstas, Srinivasan Iyer, Yejin Choi, Luke Zettlemoyer. ACL 2017)

## Installation

- Install Torch following the instructions [here](http://torch.ch/docs/getting-started.html).

- Then install the following packages for Torch:
```
luarocks install nn nngraph cutorch cunn cudnn hdf5
```

*(Only for training models)* 

- Install the following packages for Python 2.7: 
```
pip install numpy h5py
```

*(Only for downloading the pretrained models)*

- Install the Git LFS client from [here](https://git-lfs.github.com/) **BEFORE** you clone the project. 
- Then run the following command:
```
git lfs install
```

## Quickstart (AMR Generation)
You can generate text from AMR graphs using our pre-trained model on 20M sentences from Gigaword, in two different ways:
- By running an interactive tool that reads input from `stdin`:
```
./predict_amr_single.sh [stripped|full]
```
You can optionally provide an argument that tells the system to accept either `full` AMR as described in the [annotation guidelines](), or a `stripped` version, which removes variables, senses, parentheses from leaves, and assumes a simpler markup for Named Entities (for more details and examples, see [here]()).

- By running the prediction on a single file, which contains an AMR graph per line.
```
./predict_amr.sh
```
## Details

### Prediction Options (predict_amr.sh, predict_amr_single.sh)
- `interactive_mode [0,1]`: Set `0` for predicting from a file, or `1` to predict from `stdin`.
- `model [str]`: The path to the trained model.
- `input_type [stripped|full]`: Set `full` for standard AMR graph input, or `stripped` which expects AMR graphs with no variables, senses, parentheses from leaves, and assumes a simpler markup for Named Entities (for more details and examples, see [here]()).
- `gpuid [int]`: The GPU id number.
- `src_dict, targ_dict [str]`: Path to source and target dictionaries. These are usually generated during preprocessing of the corpus. ==Note==: `src_dict` and `targ_dict` paths need to be reversed when generating text or parsing to AMR.
- `beam [int]`: The beam size of the decoder (default is 5).
- `replace_unk [0,1]`: Replace unknown words with either the input token that has the highest attention weight, or the word that maps to the input token as provided in `srctarg_dict`.
- `srctarg_dict [str]`: Path to source-target dictionary to replace unknown tokens. Each line should be a source token and its corresponding target token, separated by `|||` (see `resources/training-amr-nl-alignments.txt`).

