{Platform API}
function clGetPlatformIDs(a:tcl_uint{num_entries};var b:tcl_platform_id{platforms};var c:tcl_uint{num_platforms}):tcl_int;stdcall;external OpenCLLibName;
function clGetPlatformInfo(a:tcl_platform_id{platform};b:tcl_platform_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
{Device APIs}
function clGetDeviceIDs(a:tcl_platform_id{platform};b:tcl_device_type{device_type};c:tcl_uint{num_entries};var d:tcl_device_id{devices};var e:tcl_uint{num_devices}):tcl_int;stdcall;external OpenCLLibName;
function clGetDeviceInfo(a:tcl_device_id{device};b:tcl_device_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clCreateSubDevices(a:tcl_device_id{in_device};var b:tcl_device_partition_property{properties};c:tcl_uint{num_devices};var d:tcl_device_id{out_devices};var e:tcl_uint{num_devices_ret}):tcl_int;stdcall;external OpenCLLibName;
function clRetainDevice(a:tcl_device_id{device}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseDevice(a:tcl_device_id{device}):tcl_int;stdcall;external OpenCLLibName;
function clSetDefaultDeviceCommandQueue(a:tcl_context{context};b:tcl_device_id{device};c:tcl_command_queue{command_queue}):tcl_int;stdcall;external OpenCLLibName;
function clGetDeviceAndHostTimer(a:tcl_device_id{device};var b:tcl_ulong{device_timestamp};var c:tcl_ulong{host_timestamp}):tcl_int;stdcall;external OpenCLLibName;
function clGetHostTimer(a:tcl_device_id{device};var b:tcl_ulong{host_timestamp}):tcl_int;stdcall;external OpenCLLibName;
 
{Context APIs}
function clCreateContext(var a:tcl_context_properties{properties};b:tcl_uint{num_devices};var c:tcl_device_id{devices};d:TclContextNotify;e:pointer{user_data};var f:tcl_int{errcode_ret}):tcl_context;stdcall;external OpenCLLibName;
function clCreateContextFromType(var a:tcl_context_properties{properties};b:tcl_device_type{device_type};c:TclContextNotify;d:pointer{user_data};var e:tcl_int{errcode_ret}):tcl_context;stdcall;external OpenCLLibName;
function clRetainContext(a:tcl_context{context}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseContext(a:tcl_context{context}):tcl_int;stdcall;external OpenCLLibName;
function clGetContextInfo(a:tcl_context{context};b:tcl_context_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
{Command Queue APIs}
function clCreateCommandQueueWithProperties(a:tcl_context{context};b:tcl_device_id{device};var c:tcl_queue_properties{properties};var d:tcl_int{errcode_ret}):tcl_command_queue;stdcall;external OpenCLLibName;
function clRetainCommandQueue(a:tcl_command_queue{command_queue}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseCommandQueue(a:tcl_command_queue{command_queue}):tcl_int;stdcall;external OpenCLLibName;
function clGetCommandQueueInfo(a:tcl_command_queue{command_queue};b:tcl_command_queue_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
{Memory Object APIs}
function clCreateBuffer(a:tcl_context{context};b:tcl_mem_flags{flags};c:size_t{size};d:pointer{host_ptr};var e:tcl_int{errcode_ret}):tcl_mem;stdcall;external OpenCLLibName;
function clCreateSubBuffer(a:tcl_mem{buffer};b:tcl_mem_flags{flags};c:tcl_buffer_create_type{buffer_create_type};d:pointer{buffer_create_info};var e:tcl_int{errcode_ret}):tcl_mem;stdcall;external OpenCLLibName;
function clCreateImage(a:tcl_context{context};b:tcl_mem_flags{flags};var c:tcl_image_format{image_format};var d:tcl_image_desc{image_desc};e:pointer{host_ptr};var f:tcl_int{errcode_ret}):tcl_mem;stdcall;external OpenCLLibName;
function clCreatePipe(a:tcl_context{context};b:tcl_mem_flags{flags};c:tcl_uint{pipe_packet_size};d:tcl_uint{pipe_max_packets};var e:tcl_pipe_properties{properties};var f:tcl_int{errcode_ret}):tcl_mem;stdcall;external OpenCLLibName;
function clRetainMemObject(a:tcl_mem{memobj}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseMemObject(a:tcl_mem{memobj}):tcl_int;stdcall;external OpenCLLibName;
function clGetSupportedImageFormats(a:tcl_context{context};b:tcl_mem_flags{flags};c:tcl_mem_object_type{image_type};d:tcl_uint{num_entries};var e:tcl_image_format{image_formats};var f:tcl_uint{num_image_formats}):tcl_int;stdcall;external OpenCLLibName;
function clGetMemObjectInfo(a:tcl_mem{memobj};b:tcl_mem_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clGetImageInfo(a:tcl_mem{image};b:tcl_image_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clGetPipeInfo(a:tcl_mem{pipe};b:tcl_pipe_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;

function clSetMemObjectDestructorCallback(a:tcl_mem{memobj};b:TclMemObjectNotify;c:pointer{user_data}):tcl_int;stdcall;external OpenCLLibName;
{SVM Allocation APIs}
function clSVMAlloc(a:tcl_context{context};b:tcl_svm_mem_flags{flags};c:size_t{size};d:tcl_uint{alignment}):pointer;stdcall;external OpenCLLibName;
procedure clSVMFree(a:tcl_context{context};b:pointer{svm_pointer});stdcall;external OpenCLLibName;
{Sampler APIs}
function clCreateSamplerWithProperties(a:tcl_context{context};var b:tcl_sampler_properties{normalized_coords};var c:tcl_int{errcode_ret}):tcl_sampler;stdcall;external OpenCLLibName;
function clRetainSampler(a:tcl_sampler{sampler}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseSampler(a:tcl_sampler{sampler}):tcl_int;stdcall;external OpenCLLibName;
function clGetSamplerInfo(a:tcl_sampler{sampler};b:tcl_sampler_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
{Program Object APIs}
function clCreateProgramWithSource(a:tcl_context{context};b:tcl_uint{count};var c:pansichar{strings};var d:size_t{lengths};var e:tcl_int{errcode_ret}):tcl_program;stdcall;external OpenCLLibName;
function clCreateProgramWithBinary(a:tcl_context{context};b:tcl_uint{num_devices};var c:tcl_device_id{device_list};var d:size_t{lengths};var e:pansichar{binaries};var f:tcl_int{binary_status};var g:tcl_int{errcode_ret}):tcl_program;stdcall;external OpenCLLibName;
function clCreateProgramWithBuiltInKernels(a:tcl_context{context};b:tcl_uint{num_devices};var c:tcl_device_id{device_list};d:pansichar{kernel_names};var e:tcl_int{errcode_ret}):tcl_program;stdcall;external OpenCLLibName;
function clCreateProgramWithIL(a:tcl_context{context};b:pointer{il};c:size_t{length};var d:tcl_int{errcode_ret}):tcl_program;stdcall;external OpenCLLibName;

function clRetainProgram(a:tcl_program{program}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseProgram(a:tcl_program{program}):tcl_int;stdcall;external OpenCLLibName;
function clBuildProgram(a:tcl_program{program};b:tcl_uint{num_devices};var c:tcl_device_id{device_list};d:pansichar{options};e:TclProgramNotify;f:pointer{user_data}):tcl_int;stdcall;external OpenCLLibName;
function clCompileProgram(a:tcl_program{program};b:tcl_uint{num_devices};var c:tcl_device_id{device_list};d:pansichar{options};e:tcl_uint{num_input_headers};var f:tcl_program{input_headers};var g:pansichar{header_include_names};h:TclProgramNotify;i:pointer{user_data}):tcl_int;stdcall;external OpenCLLibName;
function clLinkProgram(a:tcl_context{context};b:tcl_uint{num_devices};var c:tcl_device_id{device_list};d:pansichar{options};e:tcl_uint{num_input_programs};var f:tcl_program{input_programs};g:TclProgramNotify;h:pointer{user_data};var i:tcl_int{errcode_ret}):tcl_program;stdcall;external OpenCLLibName;

function clUnloadPlatformCompiler(a:tcl_platform_id{platform}):tcl_int;stdcall;external OpenCLLibName;
function clGetProgramInfo(a:tcl_program{program};b:tcl_program_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clGetProgramBuildInfo(a:tcl_program{program};b:tcl_device_id{device};c:tcl_program_build_info{param_name};d:size_t{param_value_size};e:pointer{param_value};var f:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
{Kernel Object APIs}
function clCreateKernel(a:tcl_program{program};b:pansichar{kernel_name};var c:tcl_int{errcode_ret}):tcl_kernel;stdcall;external OpenCLLibName;
function clCreateKernelsInProgram(a:tcl_program{program};b:tcl_uint{num_kernels};var c:tcl_kernel{kernels};var d:tcl_uint{num_kernels_ret}):tcl_int;stdcall;external OpenCLLibName;
function clCloneKernel(a:tcl_kernel{source_kernel};var b:tcl_int{errcode_ret}):tcl_kernel;stdcall;external OpenCLLibName;
function clRetainKernel(a:tcl_kernel{kernel}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseKernel(a:tcl_kernel{kernel}):tcl_int;stdcall;external OpenCLLibName;
function clSetKernelArg(a:tcl_kernel{kernel};b:tcl_uint{arg_index};c:size_t{arg_size};d:pointer{arg_value}):tcl_int;stdcall;external OpenCLLibName;
function clSetKernelArgSVMPointer(a:tcl_kernel{kernel};b:tcl_uint{arg_index};c:pointer{arg_value}):tcl_int;stdcall;external OpenCLLibName;
function clSetKernelExecInfo(a:tcl_kernel{kernel};b:tcl_kernel_exec_info{param_name};c:size_t{param_value_size};d:pointer{param_value}):tcl_int;stdcall;external OpenCLLibName;
function clGetKernelInfo(a:tcl_kernel{kernel};b:tcl_kernel_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clGetKernelArgInfo(a:tcl_kernel{kernel};b:tcl_uint{arg_indx};c:tcl_kernel_arg_info{param_name};d:size_t{param_value_size};e:pointer{param_value};var f:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clGetKernelWorkGroupInfo(a:tcl_kernel{kernel};b:tcl_device_id{device};c:tcl_kernel_work_group_info{param_name};d:size_t{param_value_size};e:pointer{param_value};var f:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clGetKernelSubGroupInfo(a:tcl_kernel{kernel};b:tcl_device_id{device};c:tcl_kernel_sub_group_info{param_name};d:size_t{input_value_size};e:pointer{input_value};f:size_t{param_value_size};g:pointer{param_value};var h:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;

{Event Object APIs}
function clWaitForEvents(a:tcl_uint{num_events};var b:tcl_event{event_list}):tcl_int;stdcall;external OpenCLLibName;
function clGetEventInfo(a:tcl_event{event};b:tcl_event_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
function clCreateUserEvent(a:tcl_context{context};var b:tcl_int{errcode_ret}):tcl_event;stdcall;external OpenCLLibName;
function clRetainEvent(a:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clReleaseEvent(a:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clSetUserEventStatus(a:tcl_event{event};b:tcl_int{execution_status}):tcl_int;stdcall;external OpenCLLibName;
function clSetEventCallback(a:tcl_event{event};b:tcl_int{command_exec_callback_type};c:TclEventNotify;d:pointer{user_data}):tcl_int;stdcall;external OpenCLLibName;
{Profiling APIs}
function clGetEventProfilingInfo(a:tcl_event{event};b:tcl_profiling_info{param_name};c:size_t{param_value_size};d:pointer{param_value};var e:size_t{param_value_size_ret}):tcl_int;stdcall;external OpenCLLibName;
{Flush and Finish APIs}
function clFlush(a:tcl_command_queue{command_queue}):tcl_int;stdcall;external OpenCLLibName;
function clFinish(a:tcl_command_queue{command_queue}):tcl_int;stdcall;external OpenCLLibName;
{Enqueued Commands APIs}
function clEnqueueReadBuffer(a:tcl_command_queue{command_queue};b:tcl_mem{buffer};c:tcl_bool{blocking_read};d:size_t{offset};e:size_t{size};f:pointer{ptr};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueReadBufferRect(a:tcl_command_queue{command_queue};b:tcl_mem{buffer};c:tcl_bool{blocking_read};var d:size_t{buffer_offset};var e:size_t{host_offset};var f:size_t{region};g:size_t{buffer_row_pitch};h:size_t{buffer_slice_pitch};i:size_t{host_row_pitch};j:size_t{host_slice_pitch};k:pointer{ptr};l:tcl_uint{num_events_in_wait_list};var m:tcl_event{event_wait_list};var n:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueWriteBuffer(a:tcl_command_queue{command_queue};b:tcl_mem{buffer};c:tcl_bool{blocking_write};d:size_t{offset};e:size_t{size};f:pointer{ptr};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueWriteBufferRect(a:tcl_command_queue{command_queue};b:tcl_mem{buffer};c:tcl_bool{blocking_write};var d:size_t{buffer_offset};var e:size_t{host_offset};var f:size_t{region};g:size_t{buffer_row_pitch};h:size_t{buffer_slice_pitch};i:size_t{host_row_pitch};j:size_t{host_slice_pitch};k:pointer{ptr};l:tcl_uint{num_events_in_wait_list};var m:tcl_event{event_wait_list};var n:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueFillBuffer(a:tcl_command_queue{command_queue};b:tcl_mem{buffer};c:pointer{pattern};d:size_t{pattern_size};e:size_t{offset};f:size_t{size};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueCopyBuffer(a:tcl_command_queue{command_queue};b:tcl_mem{src_buffer};c:tcl_mem{dst_buffer};d:size_t{src_offset};e:size_t{dst_offset};f:size_t{size};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueCopyBufferRect(a:tcl_command_queue{command_queue};b:tcl_mem{src_buffer};c:tcl_mem{dst_buffer};var d:size_t{src_origin};var e:size_t{dst_origin};var f:size_t{region};g:size_t{src_row_pitch};h:size_t{src_slice_pitch};i:size_t{dst_row_pitch};j:size_t{dst_slice_pitch};k:tcl_uint{num_events_in_wait_list};var l:tcl_event{event_wait_list};var m:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueReadImage(a:tcl_command_queue{command_queue};b:tcl_mem{image};c:tcl_bool{blocking_read};var d:size_t{origin[3]};var e:size_t{region[3]};f:size_t{row_pitch};g:size_t{slice_pitch};h:pointer{ptr};i:tcl_uint{num_events_in_wait_list};var j:tcl_event{event_wait_list};var k:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueWriteImage(a:tcl_command_queue{command_queue};b:tcl_mem{image};c:tcl_bool{blocking_write};var d:size_t{origin[3]};var e:size_t{region[3]};f:size_t{input_row_pitch};g:size_t{input_slice_pitch};h:pointer{ptr};i:tcl_uint{num_events_in_wait_list};var j:tcl_event{event_wait_list};var k:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueFillImage(a:tcl_command_queue{command_queue};b:tcl_mem{image};c:pointer{fill_color};var d:size_t{origin[3]};var e:size_t{region[3]};f:tcl_uint{num_events_in_wait_list};var g:tcl_event{event_wait_list};var h:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueCopyImage(a:tcl_command_queue{command_queue};b:tcl_mem{src_image};c:tcl_mem{dst_image};var d:size_t{src_origin[3]};var e:size_t{dst_origin[3]};var f:size_t{region[3]};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueCopyImageToBuffer(a:tcl_command_queue{command_queue};b:tcl_mem{src_image};c:tcl_mem{dst_buffer};var d:size_t{src_origin[3]};var e:size_t{region[3]};f:size_t{dst_offset};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueCopyBufferToImage(a:tcl_command_queue{command_queue};b:tcl_mem{src_buffer};c:tcl_mem{dst_image};d:size_t{src_offset};var e:size_t{dst_origin[3]};var f:size_t{region[3]};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueMapBuffer(a:tcl_command_queue{command_queue};b:tcl_mem{buffer};c:tcl_bool{blocking_map};d:tcl_map_flags{map_flags};e:size_t{offset};f:size_t{size};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event};var j:tcl_int{errcode_ret}):pointer;stdcall;external OpenCLLibName;
function clEnqueueMapImage(a:tcl_command_queue{command_queue};b:tcl_mem{image};c:tcl_bool{blocking_map};d:tcl_map_flags{map_flags};var e:size_t{origin[3]};var f:size_t{region[3]};var g:size_t{image_row_pitch};var h:size_t{image_slice_pitch};i:tcl_uint{num_events_in_wait_list};var j:tcl_event{event_wait_list};var k:tcl_event{event};var l:tcl_int{errcode_ret}):pointer;stdcall;external OpenCLLibName;
function clEnqueueUnmapMemObject(a:tcl_command_queue{command_queue};b:tcl_mem{memobj};c:pointer{mapped_ptr};d:tcl_uint{num_events_in_wait_list};var e:tcl_event{event_wait_list};var f:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueMigrateMemObjects(a:tcl_command_queue{command_queue};b:tcl_uint{num_mem_objects};var c:tcl_mem{mem_objects};d:tcl_mem_migration_flags{flags};e:tcl_uint{num_events_in_wait_list};var f:tcl_event{event_wait_list};var g:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueNDRangeKernel(a:tcl_command_queue{command_queue};b:tcl_kernel{kernel};c:tcl_uint{work_dim};var d:size_t{global_work_offset};var e:size_t{global_work_size};var f:size_t{local_work_size};g:tcl_uint{num_events_in_wait_list};var h:tcl_event{event_wait_list};var i:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueNativeKernel(a:tcl_command_queue{command_queue};b:		 TclEnqueueUserProc;c:pointer{args};d:size_t{cb_args};e:tcl_uint{num_mem_objects};var f:tcl_mem{mem_list};var g:pointer{args_mem_loc};h:tcl_uint{num_events_in_wait_list};var i:tcl_event{event_wait_list};var j:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueMarkerWithWaitList(a:tcl_command_queue{command_queue};b:tcl_uint{num_events_in_wait_list};var c:tcl_event{event_wait_list};var d:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueBarrierWithWaitList(a:tcl_command_queue{command_queue};b:tcl_uint{num_events_in_wait_list};var c:tcl_event{event_wait_list};var d:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueSVMFree(a:tcl_command_queue{command_queue};b:tcl_uint{num_svm_pointers};c:Pclpointer{svm_pointers[]};d:TClSVMFreeProc;e:pointer{user_data};f:tcl_uint{num_events_in_wait_list};var g:tcl_event{event_wait_list};var h:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueSVMMemcpy(a:tcl_command_queue{command_queue};b:tcl_bool{blocking_copy};c:pointer{dst_ptr};d:pointer{src_ptr};e:size_t{size};f:tcl_uint{num_events_in_wait_list};var g:tcl_event{event_wait_list};var h:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueSVMMemFill(a:tcl_command_queue{command_queue};b:pointer{svm_ptr};c:pointer{pattern};d:size_t{pattern_size};e:size_t{size};f:tcl_uint{num_events_in_wait_list};var g:tcl_event{event_wait_list};var h:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueSVMMap(a:tcl_command_queue{command_queue};b:tcl_bool{blocking_map};c:tcl_map_flags{flags};d:pointer{svm_ptr};e:size_t{size};f:tcl_uint{num_events_in_wait_list};var g:tcl_event{event_wait_list};var h:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueSVMUnmap(a:tcl_command_queue{command_queue};b:pointer{svm_ptr};c:tcl_uint{num_events_in_wait_list};var d:tcl_event{event_wait_list};var e:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueSVMMigrateMem(a:tcl_command_queue{command_queue};b:tcl_uint{num_svm_pointers};var c:pointer{svm_pointers};var d:size_t{sizes};e:tcl_mem_migration_flags{flags};f:tcl_uint{num_events_in_wait_list};var g:tcl_event{event_wait_list};var h:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;

{Extension function access
^
^ Returns the extension function address for the given function name
^ or NULL if a valid function can not be found. The client must
^ check to make sure the address is not NULL before using or 
^ calling the returned function address.
}
function clGetExtensionFunctionAddressForPlatform(a:tcl_platform_id{platform};b:pansichar{func_name}):pointer;stdcall;external OpenCLLibName;

{Deprecated OpenCL 1.1 APIs}
function clCreateImage2D(a:tcl_context{context};b:tcl_mem_flags{flags};var c:tcl_image_format{image_format};d:size_t{image_width};e:size_t{image_height};f:size_t{image_row_pitch};g:pointer{host_ptr};var h:tcl_int{errcode_ret}):tcl_mem;stdcall;external OpenCLLibName;
function clCreateImage3D(a:tcl_context{context};b:tcl_mem_flags{flags};var c:tcl_image_format{image_format};d:size_t{image_width};e:size_t{image_height};f:size_t{image_depth};g:size_t{image_row_pitch};h:size_t{image_slice_pitch};i:pointer{host_ptr};var j:tcl_int{errcode_ret}):tcl_mem;stdcall;external OpenCLLibName;
function clEnqueueMarker(a:tcl_command_queue{command_queue};var b:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueWaitForEvents(a:tcl_command_queue{command_queue};b:tcl_uint{num_events};var c:tcl_event{event_list}):tcl_int;stdcall;external OpenCLLibName;
function clEnqueueBarrier(a:tcl_command_queue{command_queue}):tcl_int;stdcall;external OpenCLLibName;
function clUnloadCompiler :tcl_int;stdcall;external OpenCLLibName;
 
function clGetExtensionFunctionAddress(a:pansichar{func_name}):pointer;stdcall;external OpenCLLibName;
{Deprecated OpenCL 2.0 APIs}
function clCreateCommandQueue(a:tcl_context{context};b:tcl_device_id{device};c:tcl_command_queue_properties{properties};var d:tcl_int{errcode_ret}):tcl_command_queue;stdcall;external OpenCLLibName;
 
function clCreateSampler(a:tcl_context{context};b:tcl_bool{normalized_coords};c:tcl_addressing_mode{addressing_mode};d:tcl_filter_mode{filter_mode};var e:tcl_int{errcode_ret}):tcl_sampler;stdcall;external OpenCLLibName;
function clEnqueueTask(a:tcl_command_queue{command_queue};b:tcl_kernel{kernel};c:tcl_uint{num_events_in_wait_list};var d:tcl_event{event_wait_list};var e:tcl_event{event}):tcl_int;stdcall;external OpenCLLibName;
