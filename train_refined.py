import argparse
from sugar_utils.general_utils import str2bool
from sugar_trainers.refine import refined_training
from sugar_extractors.refined_mesh import extract_mesh_and_texture_from_refined_sugar


class AttrDict(dict):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            self.__dict__ = self

if __name__ == "__main__":
    # Parser
    parser = argparse.ArgumentParser(description='Script to refine a SuGaR model.')
    parser.add_argument('-s', '--scene_path',
                        type=str, 
                        help='path to the scene data to use.')  
    parser.add_argument('-c', '--checkpoint_path', 
                        type=str, 
                        help='path to the vanilla 3D Gaussian Splatting Checkpoint to load.')  
    parser.add_argument('-m', '--mesh_path', 
                        type=str, 
                        help='Path to the extracted mesh file to use for refinement.')  
    parser.add_argument('-o', '--output_dir',
                        type=str, default=None, 
                        help='path to the output directory.')  
    parser.add_argument('-i', '--iteration_to_load', 
                        type=int, default=7000, 
                        help='iteration to load.')  
    
    parser.add_argument('-n', '--normal_consistency_factor', type=float, default=0.1, 
                        help='Factor to multiply the normal consistency loss by.')  
    parser.add_argument('-g', '--gaussians_per_triangle', type=int, default=1, 
                        help='Number of gaussians per triangle.')  
    parser.add_argument('-v', '--n_vertices_in_fg', type=int, default=1_000_000, 
                        help='Number of vertices in the foreground (Mesh resolution). Used for computing learning rates.')  
    parser.add_argument('-f', '--refinement_iterations', type=int, default=15_000, 
                        help='Number of refinement iterations.')
    
    parser.add_argument('-b', '--bboxmin', type=str, default=None, 
                        help='Min coordinates to use for foreground.')  
    parser.add_argument('-B', '--bboxmax', type=str, default=None, 
                        help='Max coordinates to use for foreground.')  
    # (Optional) Parameters for textured mesh extraction
    parser.add_argument('-t', '--export_uv_textured_mesh', type=str2bool, default=True, 
                        help='If True, will export a textured mesh as an .obj file from the refined SuGaR model. '
                        'Computing a traditional colored UV texture should take less than 10 minutes.')
    parser.add_argument('--square_size',
                        default=8, type=int, help='Size of the square to use for the UV texture.')
    parser.add_argument('--postprocess_mesh', type=str2bool, default=False, 
                        help='If True, postprocess the mesh by removing border triangles with low-density. '
                        'This step takes a few minutes and is not needed in general, as it can also be risky. '
                        'However, it increases the quality of the mesh in some cases, especially when an object is visible only from one side.')
    parser.add_argument('--postprocess_density_threshold', type=float, default=0.1,
                        help='Threshold to use for postprocessing the mesh.')
    parser.add_argument('--postprocess_iterations', type=int, default=5,
                        help='Number of iterations to use for postprocessing the mesh.')
    
    
    parser.add_argument('--eval', type=str2bool, default=True, help='Use eval split.')
    parser.add_argument('--white_background', type=str2bool, default=False, help='Use a white background instead of black.')
    
    parser.add_argument('--gpu', type=int, default=0, help='Index of GPU device to use.')
    
    parser.add_argument('--export_ply', type=str2bool, default=True, 
                        help='If True, export a ply files with the refined 3D Gaussians at the end of the training.')

    args = parser.parse_args()
    
    # Call function
    # refined_sugar_path = refined_training(args)

    refined_sugar_path = "/export/mkrishn9/new_sugar/SuGaR/output/refined/drjohnson/sugarfine_3Dgs7000_sdfestim02_sdfnorm02_level03_decim1000000_normalconsistency01_gaussperface1/15000.pt"
    if True:
        refined_mesh_args = AttrDict({
            'scene_path': args.scene_path,
            'iteration_to_load': args.iteration_to_load,
            'checkpoint_path': args.checkpoint_path,
            'refined_model_path': refined_sugar_path,
            'mesh_output_dir': None,
            'n_gaussians_per_surface_triangle': args.gaussians_per_triangle,
            'square_size': args.square_size,
            'eval': args.eval,
            'gpu': args.gpu,
            'postprocess_mesh': args.postprocess_mesh,
            'postprocess_density_threshold': args.postprocess_density_threshold,
            'postprocess_iterations': args.postprocess_iterations,
        })
        refined_mesh_path = extract_mesh_and_texture_from_refined_sugar(refined_mesh_args)