mkdir -p work_gpu/nsys
for dir in work_gpu/models/*/; do
    model=$(basename $dir);
    model_name=${model#*_}
    [ -f $dir/iree_cuda/$model_name.iree.json ] || continue
    [ $model = 31_VisionAttention ] && continue
    echo "== $model"
    nsys profile --trace=cuda --sample=none --cpuctxsw=none --cuda-um-cpu-page-faults=true --cuda-um-gpu-page-faults=true -o /var/tmp/nsys_$model --force-overwrite=true -- $IREE_PY scripts/iree_driver.py --child $dir/iree_cuda/$model_name.iree.json $dir/${model_name}_weights.bin $dir/${model_name}_input.bin "" > /dev/null 2>&1
    nsys stats --report cuda_gpu_kern_sum --report cuda_gpu_mem_time_sum /var/tmp/nsys_$model.nsys-rep > work_gpu/nsys/$model.txt 2>&1
    rm -f /var/tmp/nsys_$model.nsys-rep /var/tmp/nsys_$model.sqlite
done
