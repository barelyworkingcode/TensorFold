# Dense-Qwen INT8 extension

Base: TensorFold v0.6.4 (6ea5ade). Original feature: upstream PR #247,
9453d33379ff48c7ae03424c4638100e09f97fd8, by Arminova.

This fork explicitly permits an opt-in lossy INT8 KV representation. It does
not promise BF16-identical replies in INT8 mode. Drafted and ordinary decoding
must agree within the same representation. The default BF16 attention kernels
remain the v0.6.4 implementation, including its grouped attention optimization.
The PR's INT8 attention lives in a separate module, dispatched by packed dtype.

Only dense Qwen on one CUDA GPU is qualified by the local tests. INT4 and TP=2
are not added. Vision plus long context needs independent capacity validation.

Install in the existing NVIDIA container:

```sh
docker exec tfold python -m pip install '/work/TensorFold-int8[vision]'
docker exec -w /work/TensorFold-int8 tfold python -m pytest -q \
  tests/cuda/test_qwen27_kv_int8.py tests/cuda/test_qwen27_forward.py \
  tests/cuda/test_attention.py tests/test_cuda_cli.py tests/test_cuda_kv_dtype.py
```

Do not use `tensorfold update` on this package: upstream lacks this feature.
Run `tools/refresh-local-int8.sh vX.Y.Z` to prepare a new checkout. The script
does not install or publish it. Inspect any conflicts, rerun these tests and
real-weight 128K/vision benchmarks, then install the new checkout explicitly.
An upstream refactor can require adaptation; this is not conflict-free forever.

Rollback to the stock release:

```sh
docker exec tfold python -m pip install '/work/TensorFold-0.6.4[vision]'
```

Real-weight experiments and the staged selection plan are saved in
`/home/jonathan/tf/bench/int8-128k/`. Test/benchmark results must be interpreted
with the actual GPU, checkpoint, template, precision and drafting settings.
