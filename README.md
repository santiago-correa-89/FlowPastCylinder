# 🚀 Collaborative Development of PINNs for Solid and Fluid Mechanics  

This repository is dedicated to the **collaborative development of Physics-Informed Neural Networks (PINNs)** applied to problems in **solid mechanics** and **fluid mechanics**. Our aim is to provide a **structured and open framework** where researchers and students can **share, validate, and extend** PINN-based approaches for solving partial differential equations relevant to these fields. By embedding **physical laws directly into the neural network training process**, PINNs offer a powerful alternative to conventional numerical methods, enabling solutions that are both **data-driven** and **physics-consistent**. This repository gathers **examples, reference material, and datasets** that can serve as a foundation for experimentation, benchmarking, and methodological improvements.  

## 📂 Repository Structure
Inside the repository, you will find test cases folders open to collaborative contributions, organized as follows:  
```
├── src/     # Source code of each example 
├── bib/     # Bibliography used in the examples  
└── data/    # Datasets for validation
- **`src/`** – Contains the different source codes dedicated to a specific case or 
PINN implementation.  
- **`bib/`** – Includes the main bibliography used for the example, with relevant references and supporting material.  
- **`data/`** – Stores datasets used for validation  
💡 This structure is designed to **facilitate collaboration**, making it easy for contributors to locate, modify, and expand the material.  

## 🐍 Repository Usage and Contribution Guidelines  
(Optional) Python Environment Setup and Contribution Steps  
### Create a Python virtual environment  
python3 -m venv .venv_InvPINNs  
### Activate the environment  
source .venv_InvPINNs/bin/activate  
### Install dependencies  
pip install -r requirements.txt  

### How to Contribute  
1. **Fork** this repository to your own GitHub account.  
2. **Create a new branch** for your changes:  
git checkout -b feature/your-feature-name  
3. **Follow the folder structure**:  
   - Place new code in `src/` inside a dedicated subfolder.  
   - Add datasets to `data/`, ensuring proper documentation.  
   - Include relevant references in `bib/` if applicable.  
4. **Document your work**:  
   - Add a `README.md` in your example folder explaining the purpose, inputs, outputs, and usage.  
   - Comment your code for clarity.  
5. **Commit & Push** your changes:  
git commit -m "Add new example for [description]"  
git push origin feature/your-feature-name  
6. **Open a Pull Request** to the main repository with a clear description.  
7. Participate in the **review process** by responding to feedback.  

🛠 If you encounter issues or have suggestions, please open an **Issue**.  
