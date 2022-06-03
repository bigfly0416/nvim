local ok, m = pcall(require, "session_manager")
if not ok then
    print("session manager not installed yet")
    return
end

m.setup({
    autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
    autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
})
