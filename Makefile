.PHONY: build push run share

IMG:=cartesi/image-ci
BASE:=/opt/riscv

build:
	docker build -t $(IMG) .

push: build
	docker push $(IMG)

pull:
	docker pull $(IMG)

run:
	docker run -it --rm $(IMG)

share:
	docker run -it --rm -v `pwd`:$(BASE)/host $(IMG)
