local ok, alpha = pcall(require, "alpha")

if not ok then
    return
end


local cfg = (require "alpha.themes.startify").config
cfg.noautocmd = true
--alpha.setup(dash.config)
alpha.setup(cfg)

