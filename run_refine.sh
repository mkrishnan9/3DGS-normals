#!/bin/bash

# Array of normal factors
normal_factors=(0.1 0.2 0.3)

# Arrays for num_coarse and refinement_time
num_coarse_refinement_time_pairs=(
    "28000 short"
    "23000 medium"
)

# GPU allocations for different scenes
drjohnson_gpus=(1 2 3)
playroom_gpus=(4 5 6)

# Function to run training and metrics for a given scene
run_scene() {
    local scene_path=$1
    local checkpoint_path=$2
    local metrics_config=$3
    local default_output_dir=$4
    local gpus=("${!5}")  # Pass GPU array as a reference
    local num_coarse=$6
    local refinement_time=$7

    # Loop over GPUs, each running a different normal factor
    for i in {0..2}; do
        normal_factor=${normal_factors[$i]}
        gpu=${gpus[$i]}
        echo "Running training with normal_factor $normal_factor on GPU $gpu for the current iteration"
        echo "Using --num_coarse $num_coarse and --refinement_time $refinement_time"

        # Run the Python training script with the GPU index and normal_factor
        python train.py -s $scene_path -c $checkpoint_path -r "sdf" \
            --normal_factor $normal_factor --num_coarse $num_coarse --refinement_time $refinement_time --gpu $gpu && \
        
        # Run the metrics script on the same GPU
        python metrics.py --scene_config $metrics_config -r "sdf" \
            --normal_factor $normal_factor --refinement_time $refinement_time --gpu $gpu &
    done

    # Wait for all background jobs to finish for this scene
    wait
    echo "All jobs completed for the current iteration."
}

# Main loop to run with different num_coarse and refinement_time pairs
for pair in "${num_coarse_refinement_time_pairs[@]}"; do
    num_coarse=$(echo $pair | cut -d' ' -f1)
    refinement_time=$(echo $pair | cut -d' ' -f2)
    echo "Starting run with num_coarse=$num_coarse and refinement_time=$refinement_time"

    # Run Dr. Johnson on GPUs 2-4
    run_scene "/export/mkrishn9/SuGaR/db/drjohnson" \
              "/export/mkrishn9/SuGaR/drjohnson_gs_chkpt/" \
              "/export/mkrishn9/new_sugar/SuGaR/metrics_drjohnson.json" \
              "/export/mkrishn9/new_sugar/SuGaR/output" \
              drjohnson_gpus[@] $num_coarse $refinement_time &  # Run in background

    # Run Playroom on GPUs 5-7
    run_scene "/export/mkrishn9/SuGaR/db/playroom" \
              "/export/mkrishn9/SuGaR/playroom_gs_chpkt/" \
              "/export/mkrishn9/new_sugar/SuGaR/metrics_playroom.json" \
              "/export/mkrishn9/new_sugar/SuGaR/output" \
              playroom_gpus[@] $num_coarse $refinement_time &  # Run in background

    # Wait for both scenes to finish
    wait

    # Rename the output directory for this iteration
    if [ -d "/export/mkrishn9/new_sugar/SuGaR/output" ]; then
        mv "/export/mkrishn9/new_sugar/SuGaR/output" "/export/mkrishn9/new_sugar/SuGaR/output_${num_coarse}_${refinement_time}"
        echo "Renamed output directory to output_${num_coarse}_${refinement_time}"
    else
        echo "Warning: Default output directory not found."
    fi

    echo "Completed run with num_coarse=$num_coarse and refinement_time=$refinement_time"
done

echo "All runs completed for both scenes."
