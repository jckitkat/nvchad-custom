-- python must have debugpy installed: `pip install debugpy`
-- point this at whichever interpreter has debugpy (a venv, system python, etc.)
require("dap-python").setup(vim.fn.exepath "python3")
