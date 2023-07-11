//
//  ContentView.swift
//  WaveSim
//
//  Created by user on 7/7/23.
//
//
// Example code to test C interoperability in Swift.
//
// Files include:
//     - header: ac2d.h
//     - implementation: ac2d.c
//     - module-map: WaveSim-Bridging-Header.h
//
// NOTE: When I tested with previous parameters I got a runtime of ~1.2s!
//       This is the fastest implementation we currently have. Event a few
//       times faster than the vectorized numpy code. I should still figure
//       out why my c++ code was so slow compared to the c version. Must be
//       the unneccessary class definition and such. Regardless, we can work
//       solely on the UI now rather than the finite difference. Good job so
//       far!

import SwiftUI

struct ContentView: View {
    
    
    func print_array_view() {
        // Test c array printing funciton
        //
        // WORKS!
        //
        var arr: Array<Float> = Array(repeating: 0, count: 100)
        print_array(&arr, 5)
    }
    
    
    func ac2d_compute_view() {
        // Example values for simulation
        //
        // These will actually be specified by user explicitly
        // or implicitly (e.g. dt changed to satisfy CFL condition)
        //
        // WORKS!
        //
        
        // We need to have C types (e.g. Int32)
        let nx: Int32 = 301
        let nz: Int32 = 201
        let nt: Int32 = 1000
        let sx: Int32 = Int32(floor(Double(nx/2)))
        let sz: Int32 = Int32(floor(Double(nz/2)))
        let dx: Float = 5
        let dz: Float = 5
        let dt: Float = 0.0005
        let c0: Float = 3000
        let f0: Float = 200
        let t0: Float = 0.02
        
        // Allocate initial pressure field
        var p = [Float](repeating: 0, count: Int(nx*nz))
        
        // Allocate source time function (stf)
        var stf = [Float](repeating: 0, count: Int(nt))
        
        // Fill stf with normalized and time shifted Gaussian function
        for i in 0..<nt-1 {
            stf[Int(i)] = exp(-pow(f0, 2)*pow(Float(i)*dt - t0, 2))
        }
        
        // Allocate velocity model
        var c: Array<Float> = Array(repeating: c0, count: Int(nx*nz))
        
        // Call the C finite difference code.
        // We pass the arrays by pointer.
        //
        // We will also time the code for curiosity sake
        fd2d(&p, nx, nz, dx, dz, nt, dt, &stf, sx, sz, &c)
    }

    
    func ac2d_all_p_compute_view() {
        // Same as ac2d_compute_view() (see above), but p stores
        // all pressure data at each step.
        //
        // Therefore p is of size nt*nz*nx
        
        // Example values for simulation
        //
        // These will actually be specified by user explicitly
        // or implicitly (e.g. dt changed to satisfy CFL condition)
        //
        // WORKS!
        //
        
        // We need to have C types (e.g. Int32)
        let nx: Int32 = 301
        let nz: Int32 = 201
        let nt: Int32 = 1000
        let sx: Int32 = Int32(floor(Double(nx/2)))
        let sz: Int32 = Int32(floor(Double(nz/2)))
        let dx: Float = 5
        let dz: Float = 5
        let dt: Float = 0.0005
        let c0: Float = 3000
        let f0: Float = 200
        let t0: Float = 0.02
        
        // Allocate initial pressure field
        var p = [Float](repeating: 0, count: Int(nt*nx*nz))
        
        // Allocate source time function (stf)
        var stf = [Float](repeating: 0, count: Int(nt))
        
        // Fill stf with normalized and time shifted Gaussian function
        for i in 0..<nt-1 {
            stf[Int(i)] = exp(-pow(f0, 2)*pow(Float(i)*dt - t0, 2))
        }
        
        // Allocate velocity model
        var c: Array<Float> = Array(repeating: c0, count: Int(nx*nz))
        
        // Call the C finite difference code.
        // We pass the arrays by pointer.
        //
        // We will also time the code for curiosity sake
        fd2d_all_p(&p, nx, nz, dx, dz, nt, dt, &stf, sx, sz, &c)
    }
    
    
    var body: some View {
        // View containing test functions for C/Swift
        // interoperatbility
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Run Print Array Function") {
                print_array_view()
                
                print("Finished printing array")
            }
            Button("Run Finite Difference Function") {
                let start: Double = CFAbsoluteTimeGetCurrent()
                ac2d_compute_view()
                let exec_time: Double = CFAbsoluteTimeGetCurrent() - start
                
                print("Finished Computing Finite Difference in \(exec_time) seconds")
            }
            Button("Run Finite Difference (All P) Function") {
                let start: Double = CFAbsoluteTimeGetCurrent()
                ac2d_all_p_compute_view()
                let exec_time: Double = CFAbsoluteTimeGetCurrent() - start
                
                print("Finished Computing Finite Difference in \(exec_time) seconds")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
