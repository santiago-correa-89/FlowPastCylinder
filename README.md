# Physics-Informed Neural Networks for Flow Past Cylinder (2D)

This repository contains implementations of Physics-Informed Neural Networks (PINNs) for the reconstruction of unsteady incompressible flow past a circular cylinder using different loss balancing strategies.

The objective of this repository is to provide a clean, reproducible, and extensible benchmark framework to compare weighting strategies in PINN training applied to the Navier–Stokes equations.

The implementations are inspired by the formulation introduced in:

Raissi, Perdikaris, Karniadakis (2019)
Physics-informed neural networks: A deep learning framework for solving forward and inverse problems involving nonlinear partial differential equations
Journal of Computational Physics.


---------------------------------------------------------------------

GOVERNING EQUATIONS

We consider the 2D incompressible Navier–Stokes equations:

u_t + u u_x + v u_y = -p_x + ν (u_xx + u_yy)

v_t + u v_x + v v_y = -p_y + ν (v_xx + v_yy)

u_x + v_y = 0


where:

u(x,y,t) = streamwise velocity
v(x,y,t) = transverse velocity
p(x,y,t) = pressure field
ν = kinematic viscosity

The neural network approximates:

(x, y, t) → (u, v, p)

and enforces the governing equations through automatic differentiation.


---------------------------------------------------------------------

REPOSITORY OBJECTIVES

This repository aims to:

- reconstruct velocity and pressure fields from sparse data
- compare different loss weighting strategies
- analyze convergence and stability of PINN training
- provide a structured benchmark for future developments
- reproduce the classical Flow Past Cylinder test case from PINN literature


---------------------------------------------------------------------

IMPLEMENTED PINN VARIANTS

The repository includes four training strategies:


1) Vanilla PINN

Standard formulation:

Loss = Loss_data + Loss_physics

All terms equally weighted.

Reference baseline implementation.


2) Fixed Weights (FW)

Manual weighting between data and physics losses:

Loss = λ_d Loss_data + λ_f Loss_physics

Useful for controlled experiments and sensitivity studies.


3) Adaptive Weights (AW)

Adaptive balancing between loss terms during training.

Weights evolve dynamically to improve convergence and avoid domination of one loss component over the others.


4) Residual-Based Attention (RBA)

Residual-driven adaptive weighting strategy:

λ(x) proportional to |residual(x)|

Higher residual regions receive larger attention during optimization.

Particularly effective for complex vortex-dominated flows.


---------------------------------------------------------------------

REPOSITORY STRUCTURE

.

├── data/
│   └── CFD reference datasets
│
├── PINN_NS_vanilla_inverse.ipynb
├── PINN_NS_FW_inverse.ipynb
├── PINN_NS_AW_inverse.ipynb
├── PINN_NS_RBA_inverse.ipynb
│
├── CompareVanillaPINN.m
├── organizeDataSimulation.m
│
└── README.md


data/

Contains CFD reference solutions used for training and validation.

Typical variables:

(x, y, t) → (u, v, p)


---------------------------------------------------------------------

TRAINING INPUTS AND OUTPUTS


Inputs:

x
y
t


Outputs:

u(x,y,t)
v(x,y,t)
p(x,y,t)


---------------------------------------------------------------------

LOSS FUNCTION STRUCTURE

Each implementation minimizes:

Loss = Loss_data + Loss_physics


Data Loss:

Loss_data = MSE(u_pred − u_data)
          + MSE(v_pred − v_data)


Physics Loss:

Loss_physics = MSE(f_u)
             + MSE(f_v)
             + MSE(divergence)


Residual definitions:

f_u = u_t + u u_x + v u_y + p_x − ν(u_xx + u_yy)

f_v = v_t + u v_x + v v_y + p_y − ν(v_xx + v_yy)

divergence = u_x + v_y


---------------------------------------------------------------------

BENCHMARK CASE: FLOW PAST CYLINDER

We consider the classical wake flow behind a circular cylinder at moderate Reynolds number.

This benchmark exhibits:

- vortex shedding
- pressure reconstruction challenges
- strong nonlinear coupling
- sparse-data reconstruction difficulty

making it ideal for evaluating PINN performance.


---------------------------------------------------------------------

REFERENCE

Raissi, M.
Perdikaris, P.
Karniadakis, G.E.

Physics-informed neural networks:
A deep learning framework for solving forward and inverse problems involving nonlinear partial differential equations

Journal of Computational Physics (2019)
