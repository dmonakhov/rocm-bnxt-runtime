#!/bin/bash
set -eo pipefail

LOCAL_RANK=$OMPI_COMM_WORLD_LOCAL_RANK
if [[ -z "${LOCAL_RANK}" ]]; then
    echo "Not able to detect rank, please set OMPI_COMM_WORLD_LOCAL_RANK"
    exit 1
fi

MEMBIND=""
CPUBIND=""

# GPU mapping
DBG_MAPPING_STR="RANK:${LOCAL_RANK}"
if [[ -n "${GPU_AFFINITY}" ]]; then
    IFS=',' read -ra GPU_AFFINITY_MAP <<< "$GPU_AFFINITY"
    GPU="${GPU_AFFINITY_MAP[$LOCAL_RANK]}"
    export ROCR_VISIBLE_DEVICES="$GPU"
    export CUDA_VISIBLE_DEVICES="$GPU"
    DBG_MAPPING_STR="$DBG_MAPPING_STR GPU:${GPU}"
fi
# NET mapping
if [[ -n "${NET_AFFINITY}" ]]; then
    IFS=',' read -ra NET_AFFINITY_MAP <<< "$NET_AFFINITY"
    NET=${NET_AFFINITY_MAP[$LOCAL_RANK]}
    if [ -n "${NET}" ]; then
	export UCX_NET_DEVICES="$NET:1"	
	export NCCL_IB_HCA="$NET:1"
    fi
    DBG_MAPPING_STR="$DBG_MAPPING_STR NET:${NET}"
fi
# NUMA/CPU mapping
if [[ -n "${MEM_AFFINITY}" ]]; then
    IFS=',' read -ra MEM_AFFINITY_MAP <<< "$MEM_AFFINITY"
    MEM=${MEM_AFFINITY_MAP[$LOCAL_RANK]}
    MEMBIND="--membind=${MEM}"
    DBG_MAPPING_STR="$DBG_MAPPING_STR MEM:${MEM}"
fi
if [[ -n "${CPU_AFFINITY}" ]]; then
    IFS=',' read -ra CPU_AFFINITY_MAP <<< "$CPU_AFFINITY"
    CPU=${CPU_AFFINITY_MAP[$LOCAL_RANK]}
    CPUBIND="--physcpubind=${CPU}"
    DBG_MAPPING_STR="$DBG_MAPPING_STR CPU:${CPU}"
fi

if [ -n "${MEMBIND}" ] || [ -n "${CPUBIND}" ]; then
  NUMCMD="${NUMCMD:-numactl}"
fi


#export NCCL_TOPO_DUMP_FILE=topo-$LOCAL_RANK.xml
echo "MPI_BIND_DBG: $DBG_MAPPING_STR CMD:${NUMCMD} ${CPUBIND} ${MEMBIND} $@"
${NUMCMD} ${CPUBIND} ${MEMBIND} $@

