clear all; close all; clc;

%% -----------------------
% Settings
% ------------------------
folder      = 'prediction_vanilla';
simFile     = 'cylinder_nektar_wake.mat';     % <-- FIX: define it here
points_list = [20 40];

t_init = 50; 
t_end  = 150;
eps0   = 1e-12;

% (optional) figure size
FIG_W = 26; FIG_H = 14.5;

%% --- Compare two predictions ---
cases = struct([]);

for ii = 1:numel(points_list)
    pts = points_list(ii);
    predFile = fullfile('./export', folder, sprintf('prediction_inverse_%02dpoints.mat', pts));

    [u_p, v_p, p_p, u_r, v_r, p_r, Xc, Yc, tc] = ...
        organizeDataSimulation(predFile, simFile, t_init, t_end);

    % force double
    u_p = double(u_p); v_p = double(v_p); p_p = double(p_p);
    u_r = double(u_r); v_r = double(v_r); p_r = double(p_r);
    Xc  = double(Xc);  Yc  = double(Yc);  tc  = double(tc(:));

    % use simulation/reference from first case only
    if ii == 1
        X = Xc; Y = Yc; t = tc;
        u_real = u_r; v_real = v_r; p_real = p_r;

        % unique points (for profiles/interp)
        x_nodes = X(:); y_nodes = Y(:);
        XY = [x_nodes, y_nodes];
        [XYu, ~, ic] = unique(XY, 'rows');
    else
        assert(numel(tc)==numel(t) && max(abs(tc - t)) < 1e-9, 'Time vectors differ between cases.');
        assert(isequal(size(Xc),size(X)) && max(abs(Xc(:)-X(:)))<1e-9, 'Grid X differs between cases.');
        assert(isequal(size(Yc),size(Y)) && max(abs(Yc(:)-Y(:)))<1e-9, 'Grid Y differs between cases.');
    end

    % ---- errors + % metrics (Python-style) ----
    err_u = u_p - u_real;
    err_v = v_p - v_real;
    err_p = p_p - p_real;

    rmse_u_abs_t = sqrt(mean(err_u.^2, 2));
    rmse_v_abs_t = sqrt(mean(err_v.^2, 2));
    rmse_p_abs_t = sqrt(mean(err_p.^2, 2));

    mae_u_abs_t  = mean(abs(err_u), 2);
    mae_v_abs_t  = mean(abs(err_v), 2);
    mae_p_abs_t  = mean(abs(err_p), 2);

    denom_u_t = mean(abs(u_real), 2) + eps0;
    denom_v_t = mean(abs(v_real), 2) + eps0;
    denom_p_t = mean(abs(p_real), 2) + eps0;

    relrmse_u_t = 100 * (rmse_u_abs_t ./ denom_u_t);
    relrmse_v_t = 100 * (rmse_v_abs_t ./ denom_v_t);
    relrmse_p_t = 100 * (rmse_p_abs_t ./ denom_p_t);

    relmae_u_t  = 100 * (mae_u_abs_t  ./ denom_u_t);
    relmae_v_t  = 100 * (mae_v_abs_t  ./ denom_v_t);
    relmae_p_t  = 100 * (mae_p_abs_t  ./ denom_p_t);

    denom_u_all = mean(abs(u_real(:))) + eps0;
    denom_v_all = mean(abs(v_real(:))) + eps0;
    denom_p_all = mean(abs(p_real(:))) + eps0;

    relrmse_u_all = 100 * (sqrt(mean(err_u.^2,'all')) / denom_u_all);
    relrmse_v_all = 100 * (sqrt(mean(err_v.^2,'all')) / denom_v_all);
    relrmse_p_all = 100 * (sqrt(mean(err_p.^2,'all')) / denom_p_all);

    relmae_u_all  = 100 * (mean(abs(err_u),'all') / denom_u_all);
    relmae_v_all  = 100 * (mean(abs(err_v),'all') / denom_v_all);
    relmae_p_all  = 100 * (mean(abs(err_p),'all') / denom_p_all);

    cases(ii).pts = pts;
    cases(ii).u_pred = u_p;
    cases(ii).v_pred = v_p;
    cases(ii).p_pred = p_p;

    cases(ii).relrmse_t = {relrmse_u_t, relrmse_v_t, relrmse_p_t};
    cases(ii).relmae_t  = {relmae_u_t,  relmae_v_t,  relmae_p_t};

    cases(ii).relrmse_all = [relrmse_u_all, relrmse_v_all, relrmse_p_all];
    cases(ii).relmae_all  = [relmae_u_all,  relmae_v_all,  relmae_p_all];
end

% print summary table
fprintf('\n=== Global relative errors (%%) ===\n');
for ii = 1:numel(cases)
    fprintf('%02d pts | RelRMSE: u=%.2f%% v=%.2f%% p=%.2f%% | RelMAE: u=%.2f%% v=%.2f%% p=%.2f%%\n', ...
        cases(ii).pts, ...
        cases(ii).relrmse_all(1), cases(ii).relrmse_all(2), cases(ii).relrmse_all(3), ...
        cases(ii).relmae_all(1),  cases(ii).relmae_all(2),  cases(ii).relmae_all(3));
end

%% =========================
% Figure: Positional profiles (u,v,p) in 3 subplots
t_prof = 70;
t_prof = max(1, min(numel(t), t_prof));

xCuts = [2 5 7];
xSub  = [1 8];
ySub  = [-2 2];
Ny    = 250;
yLine = linspace(ySub(1), ySub(2), Ny).';

methodScat = 'natural'; % 'linear' faster

VarName = {'u','v','p'};
VarUnit = {'m/s','m/s','Pa'};
RealVar = {u_real, v_real, p_real};

% ---- styling (tune here) ----
lwSim  = 1.3;   % simulation line width
lwPred = 1.0;   % prediction line width (slightly thinner)

mkEvery = 18;   % marker every N points
ms20    = 4;    % marker size for 20
ms40    = 4;    % marker size for 40

fig = figure('Name',sprintf('Positional profiles (20 vs 40) | t=%.3f', t(t_prof)), ...
    'Color','w','Units','centimeters','Position',[1 1 28 18]);

tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

for k = 1:3
    ax = nexttile; hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    ylim(ax, ySub);
    xlim(ax, xSub);

    % --- interpolant: Simulation at this time ---
    Zr   = RealVar{k}(t_prof,:).';
    Zr_u = accumarray(ic, Zr, [], @mean);
    Fr   = scatteredInterpolant(XYu(:,1), XYu(:,2), Zr_u, methodScat, 'none');

    % --- get simulation profiles to define scaling ---
    simProf = nan(Ny, numel(xCuts));
    for j = 1:numel(xCuts)
        x0 = xCuts(j);
        simProf(:,j) = Fr(x0*ones(Ny,1), yLine);
    end

    % center each cut around its mean (avoid overlap)
    refCut = mean(simProf, 1, 'omitnan');

    % scale factor so profiles have reasonable width compared to dx between cuts
    minDx = min(diff(sort(xCuts)));
    vals  = simProf(:); vals = vals(isfinite(vals));
    if isempty(vals)
        s = 1;
    else
        vRange = prctile(vals, [1 99]);
        if vRange(1)==vRange(2), vRange=vRange+[-1 1]*1e-6; end
        widthWanted = 0.70*minDx;     % keep profiles thin (adjust 0.15..0.35)
        s = widthWanted / ((vRange(2)-vRange(1)) + 1e-12);
    end

    % --- draw vertical markers at xCuts ---
    for j = 1:numel(xCuts)
        x0 = xCuts(j);
        plot(ax, [x0 x0], ySub, 'k:', 'LineWidth', 0.8, 'HandleVisibility','off');
        text(ax, x0, ySub(2), sprintf('  x=%.1f', x0), ...
            'VerticalAlignment','top','HorizontalAlignment','left','FontSize',10);
    end

    % --- plot each cut positioned at x0 ---
    for j = 1:numel(xCuts)
        x0 = xCuts(j);
        xLine = x0 * ones(size(yLine));

        % Simulation curve (positioned)
        x_sim = x0 + s*(simProf(:,j) - refCut(j));
        if j == 1
            plot(ax, x_sim, yLine, '-', 'LineWidth', lwSim, 'DisplayName','Simulation');
        else
            plot(ax, x_sim, yLine, '-', 'LineWidth', lwSim, 'HandleVisibility','off');
        end

        % Predictions (20 & 40)
        for ii = 1:numel(cases)
            pts = cases(ii).pts;
            Zp  = cases(ii).([VarName{k} '_pred']);
            Zp_t = Zp(t_prof,:).';
            Zp_u = accumarray(ic, Zp_t, [], @mean);
            Fp   = scatteredInterpolant(XYu(:,1), XYu(:,2), Zp_u, methodScat, 'none');

            profP  = Fp(xLine, yLine);
            x_pred = x0 + s*(profP - refCut(j));

            % marker style per case (small + sparse)
            if pts == 20
                mk = 'o'; ms = ms20;
            else
                mk = '+'; ms = ms40;
            end

            if j == 1
                plot(ax, x_pred, yLine, '-', 'LineWidth', lwPred, ...
                    'Marker', mk, 'MarkerSize', ms, ...
                    'MarkerIndices', 1:mkEvery:Ny, ...
                    'DisplayName', sprintf('PINN %02d pts', pts));
            else
                plot(ax, x_pred, yLine, '-', 'LineWidth', lwPred, ...
                    'Marker', mk, 'MarkerSize', ms, ...
                    'MarkerIndices', 1:mkEvery:Ny, ...
                    'HandleVisibility','off');
            end
        end
    end

    xlabel(ax,'$x$ (subdomain)');
    ylabel(ax,'$y$');
    title(ax, sprintf('%s profiles positioned at x-cuts (units: %s)', VarName{k}, VarUnit{k}));

    if k == 1
        legend(ax,'Location','best');
    end
end

sgtitle(sprintf('Positional profiles in subdomain: x=[%.1f,%.1f], y=[%.1f,%.1f] | t=%.3f s', ...
    xSub(1), xSub(2), ySub(1), ySub(2), t(t_prof)));