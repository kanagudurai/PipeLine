/*! //////////////////////////////////////////////////////////////////////////////////////////////
//
// \brief A library of functionalities to create meshes out of point clouds. 
//
// \date 2021-10-14
//
// \author  Intelligence Image .com
//
////////////////////////////////////////////////////////////////////////////////////////////////////////*/


#pragma once

namespace i2 {

	/*!
	* \brief Decimate a point cloud. 
	*
	* \param <float*> in_point: input point cloud. A sequence of XYZ float.
	* \param <float*> in_normal: input point cloud normals. A sequence of XYZ float. Can be NULL.
	* \param <unsigned char*> in_color: input point cloud colors. A sequence of RGB byte. Can be NULL.
	* \param <int> in_point_len: Size of in_point/in_normal/in_color data buffer in float (not points). Should be a multiple of 3.
	* \param <float**> out_point: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
	* \param <float**> out_normal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL. Must be deleted by the caller.
	* \param <unsigned char**> out_color: output point cloud colors. A sequence of RGB byte. Will be NULL if in_color is NULL. Must be deleted by the caller.
	* \param <int*> out_point_len: Size of out_point/out_normal/out_color data buffer in float (not points). Will be a multiple of 3.
	* \param <float> in_voxel_size: Size of the voxel to use.
	*
	* \return  void
	*/
	void decimate(
		float* in_point,
		float* in_normal,
		unsigned char* in_color,
		int in_point_len,
		float** out_point,
		float** out_normal,
		unsigned char** out_color,
		int* out_point_len,
		float in_voxel_size );



	/*!
	* \brief Decimate a point cloud. 
	*
	* \param <float*> in_point: input point cloud. A sequence of XYZ float.
	* \param <int> in_point_len: Size of in_point data buffer in float (not points). Should be a multiple of 3.
	* \param <float**> out_normal: output point cloud normals. A sequence of XYZ float. Must be deleted by the caller.
	* \param <int> in_knn: Number of nearest point used to compote the normal. Must be at least 2.
	*
	* \return <bool> True if the computation succeeded, false otherwise.
	*/
	bool computeNormals (
		float* in_point,
		int in_point_len,
		float** out_normal,
		int in_knn );



	/*!
	* \brief Compute Poisson cloud meshing based on vertices and point cloud normals. 
	*
	* \param <float*> in_point: input point cloud. A sequence of XYZ float.
	* \param <float*> in_normal: input point cloud normals. A sequence of XYZ float.
	* \param <int> in_point_len: Size of in_point/in_normal data buffer in float (not points). Should be a multiple of 3.
	* \param <float**> out_vert: ouput mesh vertices. A sequence of XYZ float. Must be deleted by the caller.
	* \param <int*> out_vert_len: Size of out_vert data buffer in float (not vertices). Will be a multiple of 3.
	* \param <int**> out_faceVert_id: ouput mesh faces. A sequence of 3 index refering to out_vert. Must be deleted by the caller.
	* \param <int*> out_faceVert_len: Size of out_faceVert_id data buffer in int. Will be a multiple of 3.
	* \param <float> in_opening_distance: Maximum distance from wich a mesh tri cetroid must fro the tri to be considerd valid.
	* \param <int> in_depth: Depth of the octree strucutre of the meshing method. It control the level of interpolation.
	* \param <int> in_nb_thread: Number of thread to use.
	*
	* \return  void
	*/
	void mesh (
		float* in_point,
		float* in_normal,
		int in_point_len,
		float** out_vert,
		int* out_vert_len,
		int** out_faceVert_id,
		int* out_faceVert_len,
		float in_opening_distance,
		int in_depth = 6,
		int in_nb_thread = 4);



	/*!
	* \brief Write a mesh or point cloud to an OBJ file.
	*
	* \param <float*> in_vert: input mesh vertices. A sequence of XYZ float.
	* \param <float*> in_vert_color: input mesh vertices color. A sequence of RGB float values btw 1 and 0.
	* \param <int> in_vert_len: Size of in_vert data buffer in float (not vertices). Should be a multiple of 3.
	* \param <int*> in_faceVert_id: mesh faces. A sequence of 3 index refering to in_vert.
	* \param <int> in_faceVert_len: Size of in_faceVert_id data buffer in int. Should be a multiple of 3.
	* \param <const char*> in_fileName: Filename.
	*
	* \return <bool> True if the computation succeeded, false otherwise.
	*/
	bool writeObj (
		float* in_vert,
		float* in_vert_color,
		int in_vert_len,
		int* in_faceVert_id,
		int in_faceVert_len,
		const char* in_fileName );



	/*!
	* \brief Write a mesh to an PLY file.
	*
	* \param <float*> in_vert: input mesh vertices. A sequence of XYZ float.
	* \param <unsigned char*> in_color: vertices colors. A sequence of RGB bytes Must be NULL if no color are available.
	* \param <int> in_vert_len: Size of in_vert data buffer in float (not vertices). Should be a multiple of 3.
	* \param <int*> in_faceVert_id: mesh faces. A sequence of 3 index refering to in_vert.
	* \param <int> in_faceVert_len: Size of in_faceVert_id data buffer in int. Should be a multiple of 3.
	* \param <const char*> in_fileName: Filename.
	*
	* \return <bool> True if the computation succeeded, false otherwise.
	*/
	bool writePly (
		float* in_vert,
		unsigned char* in_color,
		int in_vert_len,
		int* in_faceVert_id,
		int in_faceVert_len,
		const char* in_fileName );


	/*!
	* \brief Registration of a point cloud using a soucre point cloud and normals. Registration (rigid ICP) is done using a combination of criteria (planes and points).
	*
	* \param <float*> in_point1: input reference point cloud. A sequence of XYZ float.
	* \param <float*> in_normal1: input reference point cloud normals. A sequence of XYZ float. Can be NULL.
	* \param <int> in_point1_len: Size of in_point1/in_normal1 data buffer in float (not points). Should be a multiple of 3.
	* \param <float*> in_point2: input point cloud to register. A sequence of XYZ float.
	* \param <float*> in_normal2: input point cloud normal of in_point2. A sequence of XYZ float. Can be NULL.
	* \param <int> in_point2_len: Size of in_point2/in_normal2 data buffer in float (not points). Should be a multiple of 3.
	* \param <float**> out_point: output point cloud that is the registrated version of in_point2. A sequence of XYZ float of size in_point2_len. Must be deleted by the caller & NULL if the function return false.
	* \param <float**> out_normal: output point cloud normal that is the transformed version of in_normal2. A sequence of XYZ float of size in_point2_len. Must be deleted by the caller & NULL if the function return false or in_normal2 == NULL.
	* \param <float> in_search_distance: Radius the algorithm use arround a point to search for reference points for the registration.
	* \param <float> in_pts_prop: Proportion of importance to point versus plane. Should be btw 0 (100% planes) an 1 (100% points).
	* \param <float> in_tolerance: convergence value for the ICP.
	* \param <int> in_max_iteration: Maximum number of iteration(ICP) to try to reach in_tolerance.
	*
	* \return <bool> True if the computation converger, false otherwise.
	*/
	bool registration(float* in_point1,
		float* in_normal1,
		int in_point1_len,
		float* in_point2,
		float* in_normal2,
		int in_point2_len,
		float** out_point,
		float** out_normal,
		float in_search_distance,
		float in_pts_prop = 0.0f,
		float in_tolerance = 1e-4f,
		int in_max_iteration = 20 );
	


	/*!
	* \brief Intersect a point cloud with an axis-aligned bounding box after a Z alignement. 
	*
	* \param <float*> in_point: input point cloud. A sequence of XYZ float.
	* \param <float*> in_normal: input point cloud normals. A sequence of XYZ float. Can be NULL.
	* \param <unsigned char*> in_color: input point cloud colors. A sequence of RGB byte. Can be NULL.
	* \param <int> in_point_len: Size of in_point/in_normal/in_color data buffer in float (not points). Should be a multiple of 3.
	* \param <float**> out_point: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
	* \param <float**> out_normal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL. Must be deleted by the caller.
	* \param <unsigned char**> out_color: output point cloud colors. A sequence of RGB byte. Will be NULL if in_color is NULL. Must be deleted by the caller.
	* \param <int*> out_point_len: Size of out_point/out_normal/out_color data buffer in float (not points). Will be a multiple of 3.
	* \param <float> in_search_distance: Radius the registration use arround a point to search for reference points for the registration. Will be used to align frame in Z.
	* \param <float*> in_bb_min: BB minimum XYZ (array of 3 float).
	* \param <float*> in_bb_max: BB maximum XYZ (array of 3 float).
	*
	* \return  void
	*/
	void intersect(
		float* in_point,
		float* in_normal,
		unsigned char* in_color,
		int in_point_len,
		float** out_point,
		float** out_normal,
		unsigned char** out_color,
		int* out_point_len,
		float in_search_distance,
		float* in_bb_min,
		float* in_bb_max);
	

	/*!
	* \brief Delete an array allocated by the SDK. 
	*
	* \param <T*> in_array: input array.
	*
	* \return  void
	*/
	template<typename T>
	void deleteArray ( T * in_array ) { delete [] in_array; };
	

	/*!
	* \brief Extract point from a point cloud that are at a specified distance from a reference surface. 
	*
	* \param <float*> in_point: input point cloud. A sequence of XYZ float that represent the reference surface.
	* \param <int> in_point_len: Size of in_point data buffer in float (not points). Should be a multiple of 3.
	* \param <float*> in_point2: input point cloud where point will be extracted. A sequence of XYZ float.
	* \param <float*> in_normal2: input normal of in_point2. A sequence of XYZ float.
	* \param <int> in_point2_len: Size of in_point2/in_normal2 data buffer in float (not points). Should be a multiple of 3.
	* \param <float**> out_point: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
	* \param <float**> out_normal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL. Must be deleted by the caller.
	* \param <int*> out_point_len: Size of out_point/out_normal data buffer in float (not points). Will be a multiple of 3.
	* \param <float*> in_max_distance: distance from the reference surface where point will be extracted.
	*
	* \return  void
	*/
	void extractOutOfSurfacePoint( float* in_point, int in_point_len, float* in_point2, float* in_normal2, int in_point2_len, float **out_point, float **out_normal, int *out_point_len, float in_max_distance );



	/*!
	* \brief Intersect a point cloud with an axis-aligned bounding box 
	*
	* \param <float*> in_point: input point cloud. A sequence of XYZ float.
	* \param <unsigned char*> in_color: input point cloud color. A sequence of RGB bytes.
	* \param <int> in_point_len: Size of in_point/in_color data buffer in float/byte (not points). Should be a multiple of 3.
	* \param <float*> in_dest_point: point cloud to be colored. A sequence of XYZ float. 
	* \param <int> in_dest_point_len: Size of in_dest_point data buffer in float (not points). Should be a multiple of 3.
	* \param <unsigned char **> out_color: A sequence of in_dest_point_len RGB bytes to color in_dest_point. Must be deleted by the caller.
	*
	* \return  void
	*/
	void findPointClosestColor( float* in_point, unsigned char* in_color, int in_point_len, float *in_dest_point, int in_dest_point_len, unsigned char **out_color );



	/*!
	* \brief Process a frame. Align a point cloud to the frame and return a combined version. 
	*
	* \param <float*> in_point: input point cloud. A sequence of XYZ float.
	* \param <unsigned char*> in_color: input point cloud color. A sequence of RGB bytes.
	* \param <int> in_point_len: Size of in_point/in_color data buffer in float/byte (not points). Should be a multiple of 3.
	* \param <float*> in_point2: input point cloud. A sequence of XYZ float.
	* \param <float*> in_normal2: input normal of in_point2. A sequence of XYZ float.
	* \param <unsigned char*> in_color2: input point cloud color. A sequence of RGB bytes.
	* \param <int> in_point2_len: Size of in_point2/in_normal2/in_color2 data buffer in float/unsigned char (not points). Should be a multiple of 3.
	* \param <float**> out_point: output point cloud. A sequence of XYZ float. Must be deleted by the caller.
	* \param <float**> out_normal: output point cloud normals. A sequence of XYZ float. Will be NULL if in_normal is NULL. Must be deleted by the caller.
	* \param <unsigned char*> out_color: output point cloud color. A sequence of RGB bytes. Must be deleted by the caller.
	* \param <int*> out_point_len: Size of out_point/out_normal/out_color data buffer in float/unsigned char (not points). Will be a multiple of 3.
	* \param <float*> in_bb_min: BB minimum XYZ (array of 3 float).
	* \param <float*> in_bb_max: BB maximum XYZ (array of 3 float).
	* \param <float> in_search_distance: Radius the algorithm use arround a point to search for reference points for the registration.
	* \param <float> in_pts_prop: Proportion of importance to point versus plane. Should be btw 0 (100% planes) an 1 (100% points).
	* \param <float> in_tolerance: convergence value for the ICP.
	* \param <int> in_max_iteration: Maximum number of iteration(ICP) to try to reach in_tolerance.
	* \param <float> in_voxel_size_input: Size of the voxel to use to decimate the input frame.
	* \param <float> in_voxel_size_output: Size of the voxel to use to decimate the output cloud.
	* \param <int> in_knn: Number of nearest point used to compote the normal. Must be at least 2.
	* \return  void
	*/
	bool processFrame(
		float* in_point, unsigned char* in_color, int in_point_len, //new frame data 
		float* in_point2, float* in_normal2, unsigned char* in_color2, int in_point_len2, //aggregated data 
		float** out_point, float** out_normal, unsigned char** out_color, int* out_point_len, //result data 
		float* in_bb_min, float* in_bb_max, //bbox
		float in_search_distance, float in_pts_prop, float in_tolerance, int in_max_iteration, //registraction params
		float in_voxel_size_input, float in_voxel_size_output, //decimination params
		int knn //normal params
		);

}


	
