# Glass API

This repo develops a [plumber](https://www.rplumber.io/) API  (an analogous tool to FastAPI of Python for API Development) that classifies glass based on its type (window / non-window), using ML model (Random Forest).
My model is built using [tidymodels](https://www.tidymodels.org/) and [rangerR](https://github.com/imbs-hl/ranger) packages. The model build is **outside** the scope of docker. After the construction of my model, I exported it in an .RDS format which is used by API.

**DockerHub Repo:** [glass-api]([https://github.com/stesiam/GlassIdentificationAPI](https://hub.docker.com/r/stesiam/glass-api))

**Data Source:**  [UCI Machine Learning Repository](http://archive.ics.uci.edu/dataset/42/glass+identification)
