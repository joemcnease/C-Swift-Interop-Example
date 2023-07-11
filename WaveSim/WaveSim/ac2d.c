// C module to compute the time evolution of the 2d acoustic
// wave equation.
//
// This scheme is O(x^2) and O(t^2) accurate in space and time, respectively.
// While the accuracy of this scheme is low, it is trivial to increase it.
//


#include <stdio.h>
#include <math.h>
#include "ac2d.h"


void print_array(const float *array, const int size) {
    for (int i=0; i<size; i++) {
        printf("array[%i] = %10.5f \n", i, array[i]);
    }
}


void fill(float *array, const int size, const float val) {
    for (int i=0; i<size-1; i++) {
        array[i] = val;
    }
}


void fd2d(float *p, const int nx, const int nz, const float dx, const float dz,
          const int nt, const float dt, const float *stf, const int sx, const int sz,
          const float *c) {

    float pOld[nx*nz];
    float pNew[nx*nz];
    float d2px[nx*nz];
    float d2pz[nx*nz];

    fill(pOld, nx*nz, 0.);
    fill(pNew, nx*nz, 0.);
    fill(d2px, nx*nz, 0.);
    fill(d2pz, nx*nz, 0.);

    for (int it=0; it<nt-1; it++) {
        for (int i=0; i<nz-1; i++) {
            for (int j=1; j<nx-2; j++) {
                int idx = i*nx + j;
                d2px[idx] = (p[idx-1] - 2*p[idx] + p[idx+1]) / (dx*dx);
            }
        }
        for (int j=0; j<nx-1; j++) {
            for (int i=1; i<nz-2; i++) {
                int idx = i*nx + j;
                d2pz[idx] = (p[idx-nx] - 2*p[idx] + p[idx+nx]) / (dz*dz);
            }
        }
        for (int i=0; i<(nx*nz)-1; i++) {
            pNew[i] = 2.*p[i] - pOld[i] + (dt*dt) * (c[i]*c[i]) * (d2px[i] + d2pz[i]);
        }

        pNew[sz*nx + sx] = pNew[sz*nx + sx] + stf[it];
        for (int i=0; i<nz-1; i++) {
            for (int j=0; j<nx-1; j++) {
                int idx = i*nx + j;
                pOld[idx] = p[idx];
                p[idx] = pNew[idx];
            }
        }

        printf("Time step: %d", it);
        printf("\n");
    }
}


void fd2d_all_p(float *p, const int nx, const int nz, const float dx, const float dz,
                const int nt, const float dt, const float *stf, const int sx, const int sz,
                const float *c) {
    // Same as fd2d(float *p, ...), but p = p[nt*nx*nz] where nt is number of
    // time steps and nx*nz is the same as before.
    //
    // Notice that in this function we are required to pass float **p instead of
    // float *p because now we have a 'staggered array' of pointers.

    int psize = nx*nz;
    float pOld[nx*nz];
    float pNew[nx*nz];
    float d2px[nx*nz];
    float d2pz[nx*nz];

    fill(pOld, nx*nz, 0.);
    fill(pNew, nx*nz, 0.);
    fill(d2px, nx*nz, 0.);
    fill(d2pz, nx*nz, 0.);

    for (int it=0; it<nt-1; it++) {
        for (int i=0; i<nz-1; i++) {
            for (int j=1; j<nx-2; j++) {
                int idx = i*nx + j;
                int pidx = it*psize + idx;
                d2px[idx] = (p[pidx-1] - 2*p[pidx] + p[idx+1]) / (dx*dx);
            }
        }
        for (int j=0; j<nx-1; j++) {
            for (int i=1; i<nz-2; i++) {
                int idx = i*nx + j;
                int pidx = it*psize + idx;
                d2pz[idx] = (p[pidx-nx] - 2*p[pidx] + p[pidx+nx]) / (dz*dz);
            }
        }
        for (int i=0; i<(nx*nz)-1; i++) {
            int pidx = it*psize + i;
            pNew[i] = 2.*p[pidx] - pOld[i] + (dt*dt) * (c[i]*c[i]) * (d2px[i] + d2pz[i]);
        }

        pNew[sz*nx + sx] = pNew[sz*nx + sx] + stf[it];
        for (int i=0; i<nz-1; i++) {
            for (int j=0; j<nx-1; j++) {
                int idx = i*nx + j;
                int pidx = it*psize + idx;
                pOld[idx] = p[pidx];
                p[pidx] = pNew[idx];
            }
        }

        printf("Time step: %d", it);
        printf("\n");
    }
}
