#!/bin/bash

# Array of normal factors
normal_factors=(0.1)

# Array of scene names
scenes=("garden" "kitchen" "room" "bicycle" "counter" "bonsai" "stump")

# GPUs (1 to 7)
gpus=(1 2 3 4 5 6 7)

# Base directories
data_base_dir="/export/mkrishn9/SuGaR/mipnerf"
output_base_dir="/export/mkrishn9/new_sugar/SuGaR"

# Loop over each normal factor
# for normal_factor in "${normal_factors[@]}"; do

#     # Run each scene in parallel, assigned to a different GPU
#     for i in {0..6}; do
#         scene="${scenes[$i]}"
#         gpu="${gpus[$i]}"
#         metrics_config="/export/mkrishn9/new_sugar/SuGaR/metrics_${scene}.json"  # Scene-specific metrics file
#         chkpt_dir="/export/mkrishn9/SuGaR/${scene}_gs_chkpt/"  
#         echo "Running training for scene $scene on GPU $gpu with normal_factor $normal_factor"

#         # Run the training script
#         python train.py -s "$data_base_dir/$scene" -c "$chkpt_dir" -r "sdf" --normal_factor "$normal_factor" --gpu "$gpu" && \

#         # Run the metrics script in parallel
#         python metrics.py --scene_config "$metrics_config" -r "sdf" --normal_factor "$normal_factor" --gpu "$gpu" &

#     done

#     # Wait for all scenes to finish
#     wait

#     # Rename the output directory for the current normal factor
    

# done

# output_dir="$output_base_dir/output_ref_long"
# if [ -d "$output_base_dir/output" ]; then
#     mv "$output_base_dir/output" "$output_dir"
#     echo "Renamed output directory to $output_dir"
# else
#     echo "Warning: Default output directory not found for normal_factor $normal_factor."
# fi

# echo "Completed processing for normal_factor $normal_factor."

# echo "All normal factors processed."


for normal_factor in "${normal_factors[@]}"; do

    # Run each scene in parallel, assigned to a different GPU
    for i in {0..6}; do
        scene="${scenes[$i]}"
        gpu="${gpus[$i]}"
        coarse_path="/export/mkrishn9/new_sugar/SuGaR/mipnerf/output_mipnerf_1/coarse${scene}"  # Scene-specific coarse chpkt

        chkpt_dir="/export/mkrishn9/SuGaR/${scene}_gs_chkpt/"  
        echo "Running training for scene $scene on GPU $gpu with normal_factor $normal_factor"

        # Run the training script
        python train_mesh.py -s "$data_base_dir/$scene" -c "$chkpt_dir" -r "sdf" --normal_factor "$normal_factor" --gpu "$gpu" --coarse_path "$coarse_path" &

        
    done

    # Wait for all scenes to finish
    wait

    # Rename the output directory for the current normal factor
    

done

output_dir="$output_base_dir/output_vanilla_mipnerf"
if [ -d "$output_base_dir/output" ]; then
    mv "$output_base_dir/output" "$output_dir"
    echo "Renamed output directory to $output_dir"
else
    echo "Warning: Default output directory not found for normal_factor $normal_factor."
fi

echo "Completed processing for normal_factor $normal_factor."

echo "All normal factors processed."



