%EXTRACT_PINN SIMULATIO WINDOW
% Loads PINN prediction + simulation fields and returns windowed, aligned arrays.
%
% Inputs
%   predMatFile : .mat with u_pred,v_pred,p_pred,x,y,t  (pred: [Nt_pred x Nnodes], x,y: [Nt_pred x Nnodes])
%   simMatFile  : .mat with U_star, p_star              (U_star: [Nnodes x 2 x Nt_sim], p_star: [Nnodes x Nt_sim])
%   t_init,t_end: window indices in time (e.g., 50,150)
%
% Outputs
%   u_pred,v_pred,p_pred : [Nt x Nnodes] windowed + reordered
%   u_real,v_real,p_real : [Nt x Nnodes] windowed + reordered
%   x,y                  : [n_rows x n_cols] grid matrices
%   t                    : [Nt x 1] time vector in the window
function [u_pred, v_pred, p_pred, u_real, v_real, p_real, x, y, t] = ...
    organizeDataSimulation(predMatFile, simMatFile, t_init, t_end)

    % --------------------
    % 1) Load prediction
    % --------------------
    P = load(predMatFile, 'u_pred','v_pred','p_pred','x','y','t');
    u_pred_all = P.u_pred;
    v_pred_all = P.v_pred;
    p_pred_all = P.p_pred;
    x_all      = P.x;
    y_all      = P.y;
    t_all      = P.t(:);

    Nt_pred = size(u_pred_all,1);
    Nnodes  = size(u_pred_all,2);

    % coords are repeated over time -> take one row
    if size(x_all,1) > 1
        x_nodes = x_all(1,:).';
        y_nodes = y_all(1,:).';
    else
        x_nodes = x_all(:);
        y_nodes = y_all(:);
    end

    % --------------------
    % 2) Build grid + ordering
    % --------------------
    x_mesh = unique(x_nodes,'sorted');
    y_mesh = unique(y_nodes,'sorted');
    n_cols = numel(x_mesh);
    n_rows = numel(y_mesh);
    n_grid = n_rows*n_cols;

    assert(Nnodes == n_grid, ...
        'Nnodes=%d pero n_rows*n_cols=%d. Revisar coordenadas x,y.', Nnodes, n_grid);

    % sort nodes by (y,x) to make reshape consistent
    [~, idx] = sortrows([y_nodes, x_nodes], [1 2]);

    x_sorted = x_nodes(idx);
    y_sorted = y_nodes(idx);

    x = reshape(x_sorted, n_rows, n_cols);
    y = reshape(y_sorted, n_rows, n_cols);

    % --------------------
    % 3) Load simulation
    % --------------------
    S = load(simMatFile, 'U_star','p_star');
    U_star = S.U_star;
    p_star = S.p_star;

    % Expect U_star: [Nnodes x 2 x Nt_sim]
    % If it comes as [Nnodes x Nt_sim x 2], fix it.
    if ndims(U_star) == 3 && size(U_star,2) ~= 2 && size(U_star,3) == 2
        U_star = permute(U_star, [1 3 2]); % -> [Nnodes x 2 x Nt_sim]
    end
    assert(ndims(U_star)==3 && size(U_star,1)==Nnodes && size(U_star,2)==2, ...
        'U_star debe ser [Nnodes x 2 x Nt_sim].');

    % p_star expected: [Nnodes x Nt_sim] (if [Nnodes x 1 x Nt_sim], squeeze it)
    if ndims(p_star) == 3
        p_star = squeeze(p_star);
    end
    assert(size(p_star,1)==Nnodes, 'p_star debe tener Nnodes filas.');

    Nt_sim = size(U_star,3);

    % --------------------
    % 4) Window (clamp)
    % --------------------
    i0 = max(1, t_init);
    i1 = min([t_end, numel(t_all)]);
    assert(i0 <= i1, 'Ventana temporal inválida (i0>i1).');

    t = t_all(1:i1-i0);
    Nt = numel(t);

    % --------------------
    % 5) Extract + reorder (idx)
    % --------------------
    u_pred = u_pred_all(:, idx);
    v_pred = v_pred_all(:, idx);
    p_pred = p_pred_all(:, idx);

    u_real = squeeze(U_star(:,1,i0:i1-1)).';   % [Nt x Nnodes]
    v_real = squeeze(U_star(:,2,i0:i1-1)).';   % [Nt x Nnodes]
    p_real = p_star(:,i0:i1-1).';              % [Nt x Nnodes]

    u_real = u_real(:, idx);
    v_real = v_real(:, idx);
    p_real = p_real(:, idx);

    % sanity
    assert(all(size(u_pred)==[Nt,n_grid]), 'u_pred no es [Nt x n_grid].');
    assert(all(size(u_real)==[Nt,n_grid]), 'u_real no es [Nt x n_grid].');
end