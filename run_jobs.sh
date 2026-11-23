#!/bin/bash

# Array of normal factors
normal_factors=(0.1 0.2)

# Number of available GPUs
gpus=(1 2)

# Scene path and checkpoint path
scene_path="/export/mkrishn9/SuGaR/tandt/truck"
checkpoint_path="/export/mkrishn9/SuGaR/truck_gs_chkpt/"
metrics_config="/export/mkrishn9/new_sugar/SuGaR/metrics_truck.json"

# Directory where the default output is stored
default_output_dir="/export/mkrishn9/new_sugar/SuGaR/output"

# Outer loop to run the whole process 10 times
for j in {1..3}; do
    echo "Starting iteration $j of 10"
    
    # Loop over normal factors and GPUs to run jobs in parallel
    for i in "${!normal_factors[@]}"; do
        normal_factor=${normal_factors[$i]}
        gpu=${gpus[$i]}
        echo "Running training job with normal_factor $normal_factor on GPU $gpu in iteration $j"

        # Run the Python training script with the GPU index argument
        python train.py -s $scene_path -c $checkpoint_path -r "sdf" --normal_factor $normal_factor --gpu $gpu && \
        
        # After training finishes, run the metrics script on the same GPU
        python metrics.py --scene_config $metrics_config -r "sdf" --normal_factor $normal_factor --gpu $gpu &
    done

    # Wait for all background jobs to finish
    wait

    # After all jobs in the current iteration finish, rename the output directory
    if [ -d "$default_output_dir" ]; then
        mv "$default_output_dir" "${default_output_dir}_truck_$j"
        echo "Renamed output directory to ${default_output_dir}_truck_$j"
    else
        echo "Warning: Default output directory $default_output_dir not found."
    fi
    
done

echo "All iterations completed for truck."


# Scene path and checkpoint path
scene_path="/export/mkrishn9/SuGaR/db/drjohnson"
checkpoint_path="/export/mkrishn9/SuGaR/drjohnson_gs_chkpt/"
metrics_config="/export/mkrishn9/new_sugar/SuGaR/metrics_drjohnson.json"

# Directory where the default output is stored
default_output_dir="/export/mkrishn9/new_sugar/SuGaR/output"

# Outer loop to run the whole process 10 times
for j in {1..5}; do
    echo "Starting iteration $j of 10"
    
    # Loop over normal factors and GPUs to run jobs in parallel
    for i in "${!normal_factors[@]}"; do
        normal_factor=${normal_factors[$i]}
        gpu=${gpus[$i]}
        echo "Running training job with normal_factor $normal_factor on GPU $gpu in iteration $j"

        # Run the Python training script with the GPU index argument
        python train.py -s $scene_path -c $checkpoint_path -r "sdf" --normal_factor $normal_factor --gpu $gpu && \
        
        # After training finishes, run the metrics script on the same GPU
        python metrics.py --scene_config $metrics_config -r "sdf" --normal_factor $normal_factor --gpu $gpu &
    done

    # Wait for all background jobs to finish
    wait

    # After all jobs in the current iteration finish, rename the output directory
    if [ -d "$default_output_dir" ]; then
        mv "$default_output_dir" "${default_output_dir}_drjohnson_$j"
        echo "Renamed output directory to ${default_output_dir}_drjohnson_$j"
    else
        echo "Warning: Default output directory $default_output_dir not found."
    fi
    
done

echo "All iterations completed for drjohnson."


# Scene path and checkpoint path
scene_path="/export/mkrishn9/SuGaR/db/playroom"
checkpoint_path="/export/mkrishn9/SuGaR/playroom_gs_chpkt/"
metrics_config="/export/mkrishn9/new_sugar/SuGaR/metrics_playroom.json"

# Directory where the default output is stored
default_output_dir="/export/mkrishn9/new_sugar/SuGaR/output"

# Outer loop to run the whole process 10 times
for j in {1..5}; do
    echo "Starting iteration $j of 10"
    
    # Loop over normal factors and GPUs to run jobs in parallel
    for i in "${!normal_factors[@]}"; do
        normal_factor=${normal_factors[$i]}
        gpu=${gpus[$i]}
        echo "Running training job with normal_factor $normal_factor on GPU $gpu in iteration $j"

        # Run the Python training script with the GPU index argument
        python train.py -s $scene_path -c $checkpoint_path -r "sdf" --normal_factor $normal_factor --gpu $gpu && \
        
        # After training finishes, run the metrics script on the same GPU
        python metrics.py --scene_config $metrics_config -r "sdf" --normal_factor $normal_factor --gpu $gpu &
    done

    # Wait for all background jobs to finish
    wait

    # After all jobs in the current iteration finish, rename the output directory
    if [ -d "$default_output_dir" ]; then
        mv "$default_output_dir" "${default_output_dir}_playroom_$j"
        echo "Renamed output directory to ${default_output_dir}_playroom_$j"
    else
        echo "Warning: Default output directory $default_output_dir not found."
    fi
    
done

echo "All iterations completed for playroom."