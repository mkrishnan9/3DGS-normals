#!/bin/bash


# Base directories for the first script
data_base_dir="/export/mkrishn9/SuGaR/mipnerf"
output_base_dir="/export/mkrishn9/SuGaR"
metrics_dir="/export/mkrishn9/new_sugar/SuGaR"



# Array of normal factors for the second script
normal_factors=(0.1 0.2)

# Array of additional scene names for the second script
additional_scenes=("garden" "kitchen" "room" "bicycle" "counter" "bonsai" "stump")

# GPUs (1 to 7)
gpus=(1 2 3 4 5 6 7)

# Loop over each normal factor in the second script
for normal_factor in "${normal_factors[@]}"; do

    # Run each additional scene in parallel, assigned to a different GPU
    for i in {0..6}; do
        scene="${additional_scenes[$i]}"
        gpu="${gpus[$i]}"
        metrics_config="/export/mkrishn9/new_sugar/SuGaR/metrics_${scene}.json"  # Scene-specific metrics file
        chkpt_dir="/export/mkrishn9/SuGaR/${scene}_gs_chkpt/"  
        echo "Running training for scene $scene on GPU $gpu with normal_factor $normal_factor"

        # Run the training script
        python train.py -s "$data_base_dir/$scene" -c "$chkpt_dir" -r "sdf" --normal_factor "$normal_factor" --gpu "$gpu"  && \

        # Run the metrics script in parallel
        python metrics.py --scene_config "$metrics_config" -r "sdf" --normal_factor "$normal_factor" --gpu "$gpu" &

    done

    # Wait for all scenes to finish
    wait

    

    echo "Completed processing for normal_factor $normal_factor."
done

echo "All normal factors processed."