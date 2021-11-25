FROM public.ecr.aws/lambda/python:3.8

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
  cd /usr/local/bin && \
  ln -sf /opt/poetry/bin/poetry && \
  poetry config virtualenvs.create false


COPY ./pyproject.toml ./poetry.lock* ${LAMBDA_TASK_ROOT}/

WORKDIR ${LAMBDA_TASK_ROOT}

RUN poetry install --no-root

COPY . ${LAMBDA_TASK_ROOT}

CMD [ "function.main.handler" ]