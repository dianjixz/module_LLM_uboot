# MODULE_LLM_UBOOT
Patch for the uboot adapted for the module_llm development board.  
Compilation will automatically download and apply the relevant patches to compile into a uboot project.  


auto compile:
```bash
make ARCH=arm CROSS_COMPILE=aarch64-none-linux-gnu- dtb-y=m5stack-ax630c-module-llm.dtb DEVICE_TREE=m5stack-ax630c-module-llm EXTRA_CFLAGS=-DUBOOT_IMG_HEADER_BASE=0x5C000000 -j `nproc`
```

just Extract:
```bash
make Extracting
```

just Patch:
```bash
make Patching
```

just Configur:
```bash
make Configuring
```