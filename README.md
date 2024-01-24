# Glass API

[![Docker Image CI](https://github.com/stesiam/GlassIdentificationAPI/actions/workflows/docker-image.yml/badge.svg)](https://github.com/stesiam/GlassIdentificationAPI/actions/workflows/docker-image.yml)

This repo develops a [plumber](https://www.rplumber.io/) API  (an analogous tool to FastAPI of Python for API Development) that classifies glass based on its type (window / non-window), using ML model (Random Forest).
My model is built using [tidymodels](https://www.tidymodels.org/) and [ranger](https://github.com/imbs-hl/ranger) packages. The model build is **outside** the scope of docker. After the construction of my model, I exported it in an .RDS format which is used by API.

You can get the image by running the following command in your terminal:

```bash
docker pull stesiam/glass-api
```

To run the image:

```bash
docker run -p 8000:8000 stesiam/glass-api
```

When you run the image, the API documentation will be available at <a href="http://127.0.0.1:8000/__docs__/">http://127.0.0.1:8000/__docs__/</a>

**Note :** In case you get a permission error, consider to use <b><i>sudo</i></b> on the aforementionned commands.

<hr>

📦 **DockerHub Repo:** [glass-api](https://hub.docker.com/r/stesiam/glass-api)

💾 **Data Source:**  [UCI Machine Learning Repository](http://archive.ics.uci.edu/dataset/42/glass+identification)
