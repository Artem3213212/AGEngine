PCL_mem=^tCL_mem;
PCL_program=^tCL_program;
PCL_event=^tCL_event;
Pclpointer=^pointer;
TclMemObjectNotify = procedure(memob: PCL_mem; user_data: Pointer);stdcall;
TclContextNotify = procedure(const Name: PAnsiChar; const Data: Pointer; Size: Size_t; Data2: Pointer);stdcall;
TclProgramNotify = procedure(_program: PCL_program; user_data: Pointer);stdcall;
TclEventNotify = procedure(event: PCL_event; cl_int: tCL_int; p: Pointer);stdcall;
TclEnqueueUserProc = procedure(userdata: Pointer);stdcall;
TClSVMFreeProc=procedure(queue:tcl_command_queue;num_svm_pointers:tcl_uint;svm_pointers:Pclpointer;user_data:pointer);stdcall;