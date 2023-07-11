//
//  ac2d.h
//  WaveSim
//
//  Created by user on 7/7/23.
//

#ifndef ac2d_h
#define ac2d_h


void fd2d(float *p, const int nx, const int nz, const float dx, const float dz,
          const int nt, const float dt, const float *stf, const int sx, const int sz,
          const float *c);


void fd2d_all_p(float *p, const int nx, const int nz, const float dx, const float dz,
          const int nt, const float dt, const float *stf, const int sx, const int sz,
          const float *c);


void print_array(const float *array, const int size);


void save_pressure(const float *p, const int nx, const int nz, const char *filename);


void fill(float *array, const int size, const float val);


#endif /* ac2d_h */
