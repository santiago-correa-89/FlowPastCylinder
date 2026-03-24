# 🌀 Physics-Informed Neural Networks for Flow Past Cylinder (2D)

This repository provides implementations of **Physics-Informed Neural Networks (PINNs)** for reconstructing **unsteady incompressible flow past a circular cylinder** using several **loss balancing strategies**.

The objective is to offer a **clean, reproducible benchmark framework** to evaluate how different weighting techniques affect convergence, stability, and reconstruction accuracy when solving the **Navier–Stokes equations** with PINNs.

The implementations follow the formulation introduced in:

> Raissi, M., Perdikaris, P., Karniadakis, G.E. (2019)  
> *Physics-informed neural networks: A deep learning framework for solving forward and inverse problems involving nonlinear partial differential equations*  
> Journal of Computational Physics

---

# 📘 Governing Equations

We solve the **2D incompressible Navier–Stokes equations**

$$
u_t + u u_x + v u_y = -p_x + \nu (u_{xx} + u_{yy})
$$

$$
v_t + u v_x + v v_y = -p_y + \nu (v_{xx} + v_{yy})
$$

$$
u_x + v_y = 0
$$

where:

- $u(x,y,t)$ = streamwise velocity  
- $v(x,y,t)$ = transverse velocity  
- $p(x,y,t)$ = pressure field  
- $\nu$ = kinematic viscosity  

The neural network approximates

$$
(x,y,t) \rightarrow (u,v,p)
$$

and enforces the governing equations through automatic differentiation.

---

# 🎯 Repository Objectives

This repository enables:

- reconstruction of velocity and pressure fields from sparse measurements
- comparison of PINN loss-balancing strategies
- evaluation of convergence stability
- benchmarking inverse Navier–Stokes reconstruction
- reproducible Flow Past Cylinder experiments

---

# 🧠 Implemented PINN Variants

Four training strategies are included:

| Method | Description |
|--------|-------------|
| **Vanilla PINN** | Equal-weight loss formulation |
| **FW (Fixed Weights)** | Manual weighting between loss terms |
| **AW (Adaptive Weights)** | Dynamically updated training weights |
| **RBA (Residual-Based Attention)** | Residual-driven spatial weighting |

---

## 1️⃣ Vanilla PINN

Standard formulation:

$$
\mathcal{L} = \mathcal{L}_{data} + \mathcal{L}_{physics}
$$

Baseline implementation used as reference.

---

## 2️⃣ Fixed Weights (FW)

Manual balancing between loss contributions:

$$
\mathcal{L} =
\lambda_d \mathcal{L}_{data}
+
\lambda_f \mathcal{L}_{physics}
$$

Useful for sensitivity analysis and controlled experiments.

---

## 3️⃣ Adaptive Weights (AW)

Training weights evolve dynamically during optimization to:

- prevent loss-term domination
- improve convergence stability
- enhance reconstruction accuracy

---

## 4️⃣ Residual-Based Attention (RBA)

Residual-driven spatial weighting strategy:

$$
\lambda(x) \propto |f(x)|
$$

Regions with higher residuals receive stronger optimization emphasis.

Particularly effective in vortex-dominated wake regions.

---

# 📂 Repository Structure

The folder `data/` contains CFD reference solutions:

$$
(x,y,t) \rightarrow (u,v,p)
$$

used for training and validation.

---

# ⚙️ Training Inputs and Outputs

### Inputs

$$
(x,y,t)
$$

### Outputs

$$
(u,v,p)
$$

---
# 📊 Loss Function Structure

Each implementation minimizes

$$
\mathcal{L} = \mathcal{L}_{data} + \mathcal{L}_{physics}
$$


### Data Loss

$$
\mathcal{L}_{data} =
\mathrm{MSE}(u_{\mathrm{pred}}-u_{\mathrm{data}})
+
\mathrm{MSE}(v_{\mathrm{pred}}-v_{\mathrm{data}})
$$


### Physics Residual Loss

$$
\mathcal{L}_{physics} =
\mathrm{MSE}(f_u)
+
\mathrm{MSE}(f_v)
+
\mathrm{MSE}(\nabla \cdot \mathbf{u})
$$


Residual definitions:

$$
f_u =
u_t + u u_x + v u_y + p_x - \nu (u_{xx}+u_{yy})
$$

$$
f_v =
v_t + u v_x + v v_y + p_y - \nu (v_{xx}+v_{yy})
$$

$$
\nabla \cdot \mathbf{u} = u_x + v_y
$$
---

# 🌊 Benchmark Case: Flow Past Cylinder

We consider the classical wake flow behind a circular cylinder at moderate Reynolds number.

This benchmark includes:

- vortex shedding dynamics
- nonlinear pressure–velocity coupling
- sparse-data reconstruction challenges
- strong sensitivity to loss balancing

making it ideal for evaluating PINN performance.

---

# 📚 Reference

Raissi, M.  
Perdikaris, P.  
Karniadakis, G.E.  

Physics-informed neural networks:  
A deep learning framework for solving forward and inverse problems involving nonlinear partial differential equations  

Journal of Computational Physics (2019)

---

# 📖 Citation and Attribution

If you use this repository in research, publications, or derivative work, please cite:

**Santiago Correa**  
**Christian Díaz-Cuadro**

Suggested citation:

Correa, S., Díaz-Cuadro, C.  
Physics-Informed Neural Networks for Flow Past Cylinder (2D):  
Loss-balancing strategies for Navier–Stokes reconstruction.  
GitHub repository.

Example BibTeX:


@misc{correa_diazcuadro_pinn_cylinder,
author = {Correa, Santiago and Díaz-Cuadro, Christian},
title = {Physics-Informed Neural Networks for Flow Past Cylinder (2D)},
year = {2026},
publisher = {GitHub},
howpublished = {\url{https://github.com/your-repository-link}}

}


If this code contributes to published results, please include a reference to the repository and clearly indicate any modifications performed.

---

# 🎓 Academic Use

This repository is intended for **research and educational purposes**.

If used in:

- journal papers
- conference papers
- theses
- technical reports

proper acknowledgment of the original authors is required.

---

# 📬 Contact

**Santiago Correa**  
scorrea@fing.edu.uy

**Christian Díaz-Cuadro**  
cdiaz@fing.edu.uy