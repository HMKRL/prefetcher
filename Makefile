CC = gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra -g

GIT_HOOKS := .git/hooks/applied

EXEC = naive_transpose sse_transpose sse_prefetch_transpose

all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

SRCS_common = main.c impl.h

naive_transpose: $(SRCS_common) naive_transpose.c
	$(CC) $(CFLAGS) \
		-DTRANSPOSE_TYPE="\"naive\"" -o $@ \
		$(SRCS_common) $@.c

sse_transpose: $(SRCS_common) sse_transpose.c
	$(CC) $(CFLAGS) \
		-DTRANSPOSE_TYPE="\"sse\"" -o $@ \
		$(SRCS_common) $@.c

sse_prefetch_transpose: $(SRCS_common) sse_transpose.c
	$(CC) $(CFLAGS) \
		-DTRANSPOSE_TYPE="\"sse_prefetch\"" -o $@ \
		$(SRCS_common) $@.c

run: $(EXEC)
	./naive_transpose
	./sse_transpose
	./sse_prefetch_transpose

cache-test: $(EXEC)
	rm -f ./*.txt
	perf stat --repeat 10 \
		-e cache-misses,cache-references,instructions,cycles \
		./naive_transpose
		perf stat --repeat 10 \
		-e cache-misses,cache-references,instructions,cycles \
		./sse_transpose
		perf stat --repeat 10 \
		-e cache-misses,cache-references,instructions,cycles \
		./sse_prefetch_transpose

clean:
	$(RM) $(EXEC)
