#ifndef TENSORFLOW_C_C_API_EX_H_
#define TENSORFLOW_C_C_API_EX_H_

#include <stddef.h>
#include <stdint.h>
#include "tensorflow/c/c_api.h"

// --------------------------------------------------------------------------
// C API Extensions for TensorFlow.
//
#ifdef SWIG
#define TF_CAPI_EXPORT
#else
#if defined(COMPILER_MSVC)
#ifdef TF_COMPILE_LIBRARY
#define TF_CAPI_EXPORT __declspec(dllexport)
#else
#define TF_CAPI_EXPORT __declspec(dllimport)
#endif  // TF_COMPILE_LIBRARY
#else
#define TF_CAPI_EXPORT __attribute__((visibility("default")))
#endif  // COMPILER_MSVC
#endif  // SWIG

#ifdef __cplusplus
extern "C" {
#endif

TF_CAPI_EXPORT extern void* TFEX_AllocGraphDefFromBuffer(TF_Buffer* graph_def_buf);

TF_CAPI_EXPORT extern void  TFEX_DeleteGraphDef(void* graph_def);
  
TF_CAPI_EXPORT extern void* TFEX_AllocMetaGraphDefFromBuffer(TF_Buffer* metagraph_buf);

TF_CAPI_EXPORT extern void  TFEX_DeleteMetaGraphDef(void* metagraph_def);

TF_CAPI_EXPORT extern void* TFEX_AllocNodeDefFromBuffer(TF_Buffer* node_def_buf);

TF_CAPI_EXPORT extern void  TFEX_DeleteNodeDef(void* node_def);

TF_CAPI_EXPORT extern void* TFEX_AllocAttrValueFromBuffer(TF_Buffer* attr_value_buf);

TF_CAPI_EXPORT extern void  TFEX_DeleteAttrValue(void* attr_value);

TF_CAPI_EXPORT extern void* TFEX_AllocOpListFromBuffer(TF_Buffer* op_list_buf);

TF_CAPI_EXPORT extern void  TFEX_DeleteOpList(void* op_list);

TF_CAPI_EXPORT extern int   TFEX_GetOpListCount(void* op_list);

TF_CAPI_EXPORT extern void* TFEX_GetOpDef(void* op_list, int index);

TF_CAPI_EXPORT extern const char* TFEX_GetOpDefName(const void* op_def);

TF_CAPI_EXPORT extern int   TFEX_GetOpDefInputArgCount(const void* op_def);

TF_CAPI_EXPORT extern void* TFEX_GetOpDefInputArg(const void* op_def, int idx);

TF_CAPI_EXPORT extern int   TFEX_GetOpDefOutputArgCount(const void* op_def);

TF_CAPI_EXPORT extern void* TFEX_GetOpDefOutputArg(const void* op_def, int idx);

TF_CAPI_EXPORT extern const char* TFEX_GetOpDefArgDefName(const void* arg_def);

TF_CAPI_EXPORT extern const char* TFEX_GetOpDefArgDefDescription(const void* arg_def);

TF_CAPI_EXPORT extern int TFEX_GetOpDefArgDefDataType(const void* arg_def);

TF_CAPI_EXPORT extern const char* TFEX_GetOpDefArgDefTypeAttr(const void* arg_def);

TF_CAPI_EXPORT extern int   TFEX_GetOpDefAttrCount(const void* op_def) ;

TF_CAPI_EXPORT extern void* TFEX_GetOpDefAttr(const void* op_def, int idx);

TF_CAPI_EXPORT extern const char* TFEX_GetOpDefAttrName(const void* op_def_attr);

TF_CAPI_EXPORT extern const char* TFEX_GetOpDefAttrDescription(const void* op_def_attr);

TF_CAPI_EXPORT extern void* TFEX_GetOpDefAttrMetadata(const void* op_def_attr);

TF_CAPI_EXPORT extern const char* TFEX_GetOpDefAttrType(const void* op_def_attr);

TF_CAPI_EXPORT extern void* TFEX_GetOpDefAttrDefaultValue(const void* op_def_attr);

TF_CAPI_EXPORT extern void* TFEX_AllocAttrValue(TF_Operation* oper, const char* attr_name,
                            TF_Status* s);

TF_CAPI_EXPORT extern int   TFEX_GetAttrValueCase(const void* attr_value);

TF_CAPI_EXPORT extern int   TFEX_GetAttrValueType(const void* attr_value);

TF_CAPI_EXPORT extern int   TFEX_AttrValueHasTensor(const void* attr_value);

TF_CAPI_EXPORT extern void* TFEX_GetAttrValue_tensor(const void* attr_value);

TF_CAPI_EXPORT extern const char* TFEX_GetAttrValue_s(const void* attr_value);

TF_CAPI_EXPORT extern int64_t TFEX_GetAttrValue_i(const void* attr_value);
	
TF_CAPI_EXPORT extern float TFEX_GetAttrValue_f(const void* attr_value);

TF_CAPI_EXPORT extern void* TFEX_AllocGraphDefFromGraph(const void* graph);

TF_CAPI_EXPORT extern void* TFEX_AddNodeDefToGraphDef(const void* graph_def);

TF_CAPI_EXPORT extern void  TFEX_DeleteGraphDef(void* graph_def);

TF_CAPI_EXPORT extern int   TFEX_GetNodeDefsCount(const void* graph_def);

TF_CAPI_EXPORT extern void* TFEX_GetNodeDef(const void* graph_def, int idx);

TF_CAPI_EXPORT extern const char* TFEX_AllocGraphDefDebugString(const void* graph_def);

TF_CAPI_EXPORT extern const char* TFEX_AllocNodeDefDebugString(const void* node_def);

TF_CAPI_EXPORT extern void  TFEX_DeleteDebugString(const char* debug_str);

TF_CAPI_EXPORT extern const char* TFEX_GetNodeDefOp(const void* node_def);

TF_CAPI_EXPORT extern const char* TFEX_GetNodeDefName(const void* node_def);

TF_CAPI_EXPORT extern int   TFEX_GetNodeDefInputCount(const void* node_def);

TF_CAPI_EXPORT extern const char* TFEX_GetNodeDefInput(const void* node_def, int idx);

TF_CAPI_EXPORT extern void* TFEX_GetNodeDefAttrMap(const void* node_def);

TF_CAPI_EXPORT extern const void* TFEX_GetAttrMapAt(const void* map, const char* key);

/*
TF_CAPI_EXPORT extern int   TFEX_GetAttrMapCount(const void* map);

TF_CAPI_EXPORT extern void* TFEX_GetAttrMapIterator(const void* map);

TF_CAPI_EXPORT extern void  TFEX_DeleteAttrMapIterator(const void* it);

TF_CAPI_EXPORT extern void* TFEX_AttrMapIteratorNext(const void* map, const void* it);

TF_CAPI_EXPORT extern const char* TFEX_AttrMapIteratorKey(const void* it);

TF_CAPI_EXPORT extern const void* TFEX_AttrMapIteratorValue(const void* it);
*/

TF_CAPI_EXPORT extern void* TFEX_GetSignatureDefMapFromMetaGraphDef(const void* metagraph_def);

TF_CAPI_EXPORT extern void* TFEX_GetSignatureDefFromMap(const void* signature_def_map, const char* key);

TF_CAPI_EXPORT extern const char* TFEX_GetInputNameFromSignatureDef(const void* signature_def);

TF_CAPI_EXPORT extern const char* TFEX_GetOutputNameFromSignatureDef(const void* signature_def);

TF_CAPI_EXPORT extern int   TFEX_TensorIntValCount(const void* tensor);

TF_CAPI_EXPORT extern int   TFEX_TensorIntVal(const void* tensor, int idx);

TF_CAPI_EXPORT extern int   TFEX_ParseTensorName(const char* name, char* first, int* first_len);

TF_CAPI_EXPORT extern const char* TFEX_ColocationAttrName();

TF_CAPI_EXPORT extern const char* TFEX_ColocationGroupPrefix();

TF_CAPI_EXPORT extern const char* TFEX_SavedModelTagServe();

TF_CAPI_EXPORT extern const char* TFEX_SavedModelTagTrain();

TF_CAPI_EXPORT extern int TFEX_RegisterOpsForTesting();

TF_CAPI_EXPORT extern int TFEX_SpecialTest1(char* protbuf, size_t protbuf_len, void(*prot_callback)(char* buf, size_t buf_len));

TF_CAPI_EXPORT extern int TFEX_SpecialTest2(char* protbuf, size_t protbuf_len, void(*prot_callback)(char* buf, size_t buf_len));

#ifdef __cplusplus
} /* end extern "C" */
#endif

#endif  // TENSORFLOW_C_C_API_EX_H_
