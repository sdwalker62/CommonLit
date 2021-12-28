SOURCE_PATH='docker-stacks/base-notebook'
CUDA_VER:=11.3.1
DIST:=ubuntu20.04
NEW_BASE:=nvidia/cuda:$(CUDA_VER)-cudnn8-runtime-$(DIST)

OWNER:=samuel62

LAB_LIST:= \
	base \
	minimal \
	scipy \
	datascience

gpu-build:
	@git submodule update --recursive --remote
	@python3 replace_container.py $(SOURCE_PATH) $(NEW_BASE)
	@cd docker-stacks && make build-all OWNER=samuel62
	@docker tag samuel62/base-notebook:latest samuel62/base-lab:cuda_$(CUDA_VER)
	@docker tag samuel62/minimal-notebook:latest samuel62/minimal-lab:cuda_$(CUDA_VER)
	@docker tag samuel62/scipy-notebook:latest samuel62/scipy-lab:cuda_$(CUDA_VER)
	@docker tag samuel62/datascience-notebook:latest samuel62/datascience-lab:cuda_$(CUDA_VER)

dev:
	@pip3 install docker
	@pip3 install tqdm
	@pip3 install -U pytest
	@pip3 install black

test/%: ## run tests for each image

test-all: $(foreach I, $(LAB_LIST), test/$(I)) ## generate all docs

docs/%: ## generate documentation for each image
	@python3 utils/generate_docs.py $(OWNER)/machine_learning_lab:$(notdir $@)_cuda_$(CUDA_VER)
docs-all: $(foreach I, $(LAB_LIST), docs/$(I)) ## generate all docs

format:
	@black .