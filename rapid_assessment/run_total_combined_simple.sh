#!/bin/bash
set -x 

mkdir -p ./misfit_data
rm -r ./misfit_data/data
rm -r ./misfit_data/stations
rm -r ./misfit_data/output
rm -r ./misfit_data/output-images
mkdir ./misfit_data/output
mkdir ./misfit_data/data   #fm

rm -rf ./GM
mkdir -p ./GM

export PYTHONPATH=$PYTHONPATH:.
export MISFIT_PREP_CONFIG="processing.json" 
export STAGED_DATA="./misfit_data/"
export OUTPUT="./GM/"

######## 1. Run waveform simulation --- Specfem3D  -- it creates the sythetic waveforms (seeds)


######## 2. Create input for download -- This workflow read the input files of the specfem3d simulation and creates the corresponding input json file for the following download workflow

dispel4py simple create_download_json.py -d '{"WJSON" :
[{"specfem3d_data_url":"https://gitlab.com/project-dare/WP6_EPOS/raw/RA_total_script/processing_elements/Download_Specfem3d_Misfit_RA/data.zip",
"output":"download_test.json"}]}'


######## 3. Get observed data -- This workflow download the obseved waveforms and stations xml
dispel4py simple download_FDSN.py -f download_test.json

# ####### 4. Get pre-processed synth and data --- Misfit Preprocess

dispel4py simple create_misfit_prep.py 

# ####### 5. Get ground motion parameters and compare them

searchpath="./misfit_data/output/"
dispel4py simple dispel4py_RA.pgm_story.py -d '{"streamProducerReal": [ {"input":"'$searchpath'" } ], "streamProducerSynth": [ {"input": "'$searchpath'"} ]}'

# ####### 6. Plot the PGM map
#dispel4py simple dispel4py_RAmapping.py
