#include <convert.hpp>

namespace cuv{

	template<class Dst,class Src>
		struct convert_impl;

	template<class Dst, class Src>
		void convert(Dst& dst, const Src& src)
		{
			convert_impl<Dst,Src>::convert(dst,src);
		};

	template<class Dst, class Src>
		struct convert_impl{

			// host (row-major) --> dev (col-major) 
			template<class __value_type, class __index_type>
				static void
				convert(        dev_dense_matrix <__value_type,  column_major,  __index_type>& dst, 
						const host_dense_matrix<__value_type,  row_major, __index_type>& src){
					if(        dst.h() != src.w()
							|| dst.w() != src.h()){

						dev_dense_matrix<__value_type,column_major,__index_type> d(src.w(),src.h());
						dst = d;
					}
					cuvSafeCall(cudaMemcpy(dst.ptr(),src.ptr(),dst.memsize(),cudaMemcpyHostToDevice));
				}

			// dev (col-major) --> host (row-major) 
			template<class __value_type, class __index_type>
				static void
				convert(        host_dense_matrix<__value_type,  row_major,  __index_type>& dst, 
						const dev_dense_matrix<__value_type,  column_major, __index_type>& src){
					if(        dst.h() != src.w()
							|| dst.w() != src.h()){
						host_dense_matrix<__value_type,row_major,__index_type> h(src.w(),src.h());
						dst = h;
					}
					cuvSafeCall(cudaMemcpy(dst.ptr(),src.ptr(),dst.memsize(),cudaMemcpyDeviceToHost));
				}

			// host (col-major) --> dev (row-major) 
			template<class __value_type, class __index_type>
				static void
				convert(        dev_dense_matrix <__value_type,  row_major,  __index_type>& dst, 
						const host_dense_matrix<__value_type,  column_major, __index_type>& src){
					if(        dst.h() != src.w()
							|| dst.w() != src.h()){

						dev_dense_matrix<__value_type,row_major,__index_type> d(src.w(),src.h());
						dst = d;
					}
					cuvSafeCall(cudaMemcpy(dst.ptr(),src.ptr(),dst.memsize(),cudaMemcpyHostToDevice));
				}

			// dev (row-major) --> host (col-major) 
			template<class __value_type, class __index_type>
				static void
				convert(        host_dense_matrix<__value_type,  column_major,  __index_type>& dst, 
						const dev_dense_matrix<__value_type,  row_major, __index_type>& src){
					if(        dst.h() != src.w()
							|| dst.w() != src.h()){
						host_dense_matrix<__value_type,column_major,__index_type> h(src.w(),src.h());
						dst = h;
					}
					cuvSafeCall(cudaMemcpy(dst.ptr(),src.ptr(),dst.memsize(),cudaMemcpyDeviceToHost));
				}
		};


#define CONVERT_INSTANTIATOR(M1,M2,N1,N2) \
		M1 N1; M2 N2; \
		convert( N1, N2 );

	namespace{
		struct instantiator{
			instantiator(){
				CONVERT_INSTANTIATOR((dev_dense_matrix<float,column_major>),(host_dense_matrix<float,row_major>),    dfc, hfr);
				CONVERT_INSTANTIATOR((dev_dense_matrix<float,row_major>),   (host_dense_matrix<float,column_major>), dfr, hfc);
			}
		} inst;
	}
#undef CONVERT_INSTANTIATOR



} // namespace cuv