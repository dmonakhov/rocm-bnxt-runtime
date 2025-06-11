# Base container runtime images for AMD/GPU with Broadcom BCM57608 NIC drivers

## Minimal base image
Runtime image contains minimal requirements for distributed workload.
- Source: Dockerfile
- Use rocm/dev-ubuntu-22.04:XX as base image 
- Install bnxt_rocelib for BCM57608 RDMA userspace libs to works correctly 

## Debug image
Runtime image with debug tools
- Source: Dockerfile.dbg
- Packages:
  - sshd, python3-pytest, dbg
  - rccl-tests (build from source)
  - perftest (build from source with ROCM support)
  - utils/mpi\_bind.sh  Bind MPI_RANK to speciffic GPU/NET/MEM/CPU

## Manual build
```
make build
make build-dbg
```
