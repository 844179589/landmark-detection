# Copyright (c) Facebook, Inc. and its affiliates.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#
#
#!/usr/bin/env sh
# bash ./scripts/300W/REG/OK-STM-SBR-REG-PFace.sh 0 W05 W05 16 16
echo script name: $0
echo $# arguments
if [ "$#" -ne 5 ] ;then
  echo "Input illegal number of parameters " $#
  echo "Need 5 parameters for gpu devices, and the stm-weight, and the sbr-weight, and the video-batch-size, and the multi-view batch size"
  exit 1
fi
gpus=$1
det=default
stm_w=$2
sbr_w=$3
sigma=3
use_gray=1
i_batch_size=32
v_batch_size=$4
m_batch_size=$5
save_path=./snapshots/STM-SBR-300W.PFaceS.${stm_w}.${sbr_w}-${det}-REG-96x96-${i_batch_size}.${v_batch_size}.${m_batch_size}

rm -rf ${save_path}

CUDA_VISIBLE_DEVICES=${gpus} python ./exps/STM-main.py \
    --train_lists ./cache_data/lists/300W/300w.train.pth \
		  ./cache_data/lists/Panoptic-FACE/simple-face-2000-nopts.pth \
    --eval_ilists ./cache_data/lists/300W/300w.test-common.pth \
                  ./cache_data/lists/300W/300w.test-challenge.pth \
                  ./cache_data/lists/300W/300w.test-full.pth \
    --eval_vlists ./cache_data/lists/300VW/300VW.test-1.pth  \
    --boxindicator ${det} --use_gray ${use_gray} \
    --num_pts 68 --data_indicator face49-STM-SBR --x68to49 \
    --procedure regression \
    --model_config ./configs/face/REG/REG.300W.config \
    --opt_config   ./configs/face/REG/ADAM.L1.300W-REG-Pface.config \
    --stm_config   ./configs/face/REG/STM.REG.300W-PFace-NOV.${stm_w}.${sbr_w}.config \
    --init_model   ./snapshots/REG-DEMO-300W-L1-${det}-96x96-32/last-info.pth \
    --save_path    ${save_path} \
    --pre_crop_expand 0.2 \
    --scale_prob 0.5 --scale_min 0.9 --scale_max 1.1 --color_disturb 0.4 \
    --offset_max 0.2 --rotate_max 30 --rotate_prob 0.9 \
    --height 96 --width 96 --sigma ${sigma} \
    --i_batch_size ${i_batch_size} --v_batch_size ${v_batch_size} --m_batch_size ${m_batch_size} \
    --print_freq 10 --print_freq_eval 1000 --eval_freq 2 --workers 25 \
    --heatmap_type gaussian 
