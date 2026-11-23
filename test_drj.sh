#!/bin/bash

# Array of normal factors
normal_factors=(0.1 0.2)

# GPUs for Dr. Johnson (0 to 3) and Playroom (4 to 7)
drjohnson_gpus=(1 2)
playroom_gpus=(3 4)
truck_gpus=(5 6)
train_gpus=(0 7)
# Function to run training and metrics for a given scene
run_scene() {
    local scene_path=$1
    local checkpoint_path=$2
    local metrics_config=$3
    local default_output_dir=$4
    local gpus=("${!5}")  # Pass GPU array as a reference

    # Loop over GPUs, each running a different normal factor
    for i in {0..1}; do
        normal_factor=${normal_factors[$i]}
        gpu=${gpus[$i]}
        echo "Running training with normal_factor $normal_factor on GPU $gpu for the current iteration"

        # Run the Python training script with the GPU index and normal_factor
        python train.py -s $scene_path -c $checkpoint_path -r "sdf" --normal_factor $normal_factor --gpu $gpu --refinement_time 'medium' && \
        
        # Run the metrics script on the same GPU
        python metrics.py --scene_config $metrics_config -r "sdf" --normal_factor $normal_factor --gpu $gpu --refinement_time 'medium' &
    done

    # Wait for all background jobs to finish for this scene
    wait
    echo "All jobs completed for the current iteration."
}

run_scene1() {
    local scene_path=$1
    local checkpoint_path=$2
    local metrics_config=$3
    local default_output_dir=$4
    local gpus=("${!5}")  # Pass GPU array as a reference

    # Loop over GPUs, each running a different normal factor
    for i in {0..1}; do
        normal_factor=${normal_factors[$i]}
        gpu=${gpus[$i]}
        echo "Running training with normal_factor $normal_factor on GPU $gpu for the current iteration"

        # Run the Python training script with the GPU index and normal_factor
        python train.py -s $scene_path -c $checkpoint_path -r "sdf" --normal_factor $normal_factor --gpu $gpu && \
        
        # Run the metrics script on the same GPU
        python metrics.py --scene_config $metrics_config -r "sdf" --normal_factor $normal_factor --gpu $gpu &
    done

    # Wait for all background jobs to finish for this scene
    wait
    echo "All jobs completed for the current iteration."
}


run_vanilla() {
    local scene_path=$1
    local checkpoint_path=$2
    local coarse_path=$3
    local default_output_dir=$4
    local gpus=("${!5}")  # Pass GPU array as a reference

    # Loop over GPUs, each running a different normal factor
    for i in {0}; do
        normal_factor=${normal_factors[$i]}
        gpu=${gpus[$i]}
        echo "Running training with normal_factor $normal_factor on GPU $gpu for the current iteration"

        # Run the Python training script with the GPU index and normal_factor
        python train_mesh.py -s $scene_path -c $checkpoint_path -r "sdf" --normal_factor $normal_factor --gpu $gpu --coarse_path $coarse_path && \
        
    done

    # Wait for all background jobs to finish for this scene
    wait
    echo "All jobs completed for the current iteration."
}


# Main loop for 4 iterations
for j in {1}; do
    echo "Starting iteration $j for both Dr. Johnson and Playroom"

    # Run Dr. Johnson on GPUs 0-3
    run_scene "/export/mkrishn9/SuGaR/db/drjohnson" \
              "/export/mkrishn9/SuGaR/drjohnson_gs_chkpt/" \
              "/export/mkrishn9/new_sugar/SuGaR/metrics_drjohnson.json" \
              "/export/mkrishn9/new_sugar/SuGaR/output" \
              drjohnson_gpus[@] &  # Run in background

    # Run Playroom on GPUs 4-7
    run_scene "/export/mkrishn9/SuGaR/db/playroom" \
              "/export/mkrishn9/SuGaR/playroom_gs_chpkt/" \
              "/export/mkrishn9/new_sugar/SuGaR/metrics_playroom.json" \
              "/export/mkrishn9/new_sugar/SuGaR/output" \
              playroom_gpus[@] &  # Run in background

    # run_scene1 "/export/mkrishn9/SuGaR/tandt/truck" \
    #           "/export/mkrishn9/SuGaR/truck_gs_chkpt/" \
    #           "/export/mkrishn9/new_sugar/SuGaR/metrics_truck.json" \
    #           "/export/mkrishn9/new_sugar/SuGaR/output" \
    #           truck_gpus[@] &  # Run in background

    # # Run Playroom on GPUs 4-7
    # run_scene1 "/export/mkrishn9/SuGaR/tandt/train" \
    #           "/export/mkrishn9/SuGaR/output/d9fdee50-4/" \
    #           "/export/mkrishn9/new_sugar/SuGaR/metrics_train.json" \
    #           "/export/mkrishn9/new_sugar/SuGaR/output" \
    #           train_gpus[@] &  # Run in background

    

    # Wait for both scenes to finish
    wait

    # Rename the output directory for this iteration
    # if [ -d "/export/mkrishn9/new_sugar/SuGaR/output" ]; then
    #     mv "/export/mkrishn9/new_sugar/SuGaR/output" "/export/mkrishn9/new_sugar/SuGaR/output_$j"
    #     echo "Renamed output directory to output_$j"
    # else
    #     echo "Warning: Default output directory not found."
    # fi

    echo "Completed iteration $j for both scenes."
done

echo "All iterations completed for both scenes."
