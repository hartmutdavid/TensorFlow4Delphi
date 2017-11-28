#include "c_api_ex.h"

#include <algorithm>
#include <limits>
#include <memory>
#include <vector>

#ifndef __ANDROID__
#include "tensorflow/cc/framework/gradients.h"
#include "tensorflow/cc/framework/ops.h"
#include "tensorflow/cc/framework/scope_internal.h"
#include "tensorflow/cc/saved_model/loader.h"
#include "tensorflow/cc/saved_model/tag_constants.h"
#endif
#include "tensorflow/c/c_api.h"
#include "tensorflow/c/c_api_internal.h"
#include "tensorflow/core/common_runtime/shape_refiner.h"
#include "tensorflow/core/framework/op_def.pb.h"
#include "tensorflow/core/framework/log_memory.h"
#include "tensorflow/core/framework/node_def_util.h"
#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/framework/partial_tensor_shape.h"
#include "tensorflow/core/framework/tensor.h"
#include "tensorflow/core/framework/tensor_shape.h"
#include "tensorflow/core/graph/graph.h"
#include "tensorflow/core/graph/graph_constructor.h"
#include "tensorflow/core/graph/node_builder.h"
#include "tensorflow/core/lib/core/coding.h"
#include "tensorflow/core/lib/core/errors.h"
#include "tensorflow/core/lib/core/status.h"
#include "tensorflow/core/lib/core/stringpiece.h"
#include "tensorflow/core/lib/gtl/array_slice.h"
#include "tensorflow/core/lib/strings/strcat.h"
#include "tensorflow/core/platform/mem.h"
#include "tensorflow/core/platform/mutex.h"
#include "tensorflow/core/platform/protobuf.h"
#include "tensorflow/core/platform/thread_annotations.h"
#include "tensorflow/core/platform/types.h"
#include "tensorflow/core/public/session.h"
#include "tensorflow/core/public/version.h"
#include "tensorflow/core/lib/core/error_codes.pb.h"
#include "tensorflow/cc/saved_model/signature_constants.h"
#include "tensorflow/core/framework/node_def.pb_text.h"

//DAV>>>   ... for special tests ...
// #include "tensorflow/core/platform/test.h"
#include "tensorflow/core/lib/io/path.h"
#include "tensorflow/core/example/example.pb.h"
#include "tensorflow/core/example/feature.pb.h"
#include "tensorflow/core/example/example.pb_text.h"
//DAV<<<


// The implementation below is at the top level instead of the
// brain namespace because we are defining 'extern "C"' functions.
using tensorflow::error::Code;
using tensorflow::errors::InvalidArgument;
using tensorflow::gtl::ArraySlice;
using tensorflow::string;
using tensorflow::strings::StrCat;
using tensorflow::AllocationDescription;
using tensorflow::DataType;
using tensorflow::Graph;
using tensorflow::GraphDef;
using tensorflow::mutex_lock;
using tensorflow::NameRangeMap;
using tensorflow::NameRangesForNode;
using tensorflow::NewSession;
using tensorflow::Node;
using tensorflow::NodeDef;
using tensorflow::NodeBuilder;
using tensorflow::OpDef;
using tensorflow::OpRegistry;
using tensorflow::PartialTensorShape;
using tensorflow::RunMetadata;
using tensorflow::RunOptions;
using tensorflow::Session;
using tensorflow::Status;
using tensorflow::Tensor;
using tensorflow::TensorBuffer;
using tensorflow::TensorId;
using tensorflow::TensorShape;
using tensorflow::TensorShapeProto;

namespace tensorflow {
	bool TF_Tensor_DecodeStrings(TF_Tensor* src, Tensor* dst, TF_Status* status);
	TF_Tensor* TF_Tensor_EncodeStrings(const Tensor& src);
}  // namespace tensorflow

extern "C" {

    void* TFEX_AllocGraphDefFromBuffer(TF_Buffer* graph_def_buf) {
		if (graph_def_buf) {
			tensorflow::GraphDef* graph_def = new tensorflow::GraphDef();
			graph_def->ParseFromArray(graph_def_buf->data, graph_def_buf->length);
			return (void*)graph_def;
		}
		else {
			return nullptr;
		}
	}

	void TFEX_DeleteGraphDef(void* graph_def) {
		if (graph_def) {
			tensorflow::GraphDef* graphdef = (tensorflow::GraphDef*)graph_def;
			delete graphdef;
		}
	}

	void* TFEX_AllocMetaGraphDefFromBuffer(TF_Buffer* metagraph_buf) {
		if (metagraph_buf) {
			tensorflow::MetaGraphDef* metagraph_def = new tensorflow::MetaGraphDef();
			metagraph_def->ParseFromArray(metagraph_buf->data, metagraph_buf->length);
			return (void*)metagraph_def;
		}
		else {
			return nullptr;
		}
	}

	void TFEX_DeleteMetaGraphDef(void* metagraph_def) {
		if (metagraph_def) {
			tensorflow::MetaGraphDef* metagraphdef = (tensorflow::MetaGraphDef*)metagraph_def;
			delete metagraphdef;
		}
	}

	void* TFEX_AllocNodeDefFromBuffer(TF_Buffer* node_def_buf) {
		if (node_def_buf) {
			tensorflow::NodeDef* node_def = new tensorflow::NodeDef();
			node_def->ParseFromArray(node_def_buf->data, node_def_buf->length);
			return (void*)node_def;
		}
		else {
			return nullptr;
		}
	}

	void TFEX_DeleteNodeDef(void* node_def) {
		if (node_def) {
			tensorflow::NodeDef* nodedef = (tensorflow::NodeDef*)node_def;
			delete nodedef;
		}
	}

	void* TFEX_AllocAttrValueFromBuffer(TF_Buffer* attr_value_buf) {
		if (attr_value_buf) {
			tensorflow::AttrValue* attr_value = new tensorflow::AttrValue();
			attr_value->ParseFromArray(attr_value_buf->data, attr_value_buf->length);
			return (void*)attr_value;
		}
		else {
			return nullptr;
		}
	}

	void TFEX_DeleteAttrValue(void* attr_value) {
		if (attr_value) {
			tensorflow::AttrValue* attrvalue = (tensorflow::AttrValue*)attr_value;
			delete attrvalue;
		}
	}

	void* TFEX_AllocOpListFromBuffer(TF_Buffer* op_list_buf) {
		if (op_list_buf) {
			tensorflow::OpList* op_list = new tensorflow::OpList();
			op_list->ParseFromArray(op_list_buf->data, op_list_buf->length);
			return (void*)op_list;
		}
		else {
			return nullptr;
		}
	}

	void TFEX_DeleteOpList(void* op_list) {
		if (op_list) {
			tensorflow::OpList* oplist = (tensorflow::OpList*)op_list;
    		delete oplist;
		}
	}

	int TFEX_GetOpListCount(void* op_list) {
		if (op_list) {
			return ((tensorflow::OpList*)op_list)->op_size();
		}
		else {
			return -1;
		}
	}

	void* TFEX_GetOpDef(void* op_list, int index) {
		if (op_list) {
			return ((tensorflow::OpList*)op_list)->mutable_op(index);
		}
		else {
			return nullptr;
		}
	}

	const char* TFEX_GetOpDefName(const void* op_def) {
		return ((OpDef*)op_def)->name().c_str();
	}

	int TFEX_GetOpDefInputArgCount(const void* op_def) {
		return ((OpDef*)op_def)->input_arg_size();
	}

	void* TFEX_GetOpDefInputArg(const void* op_def, int idx) {
		return ((OpDef*)op_def)->mutable_input_arg(idx);
	}

	int   TFEX_GetOpDefOutputArgCount(const void* op_def) {
		return ((OpDef*)op_def)->output_arg_size();
	}

	void* TFEX_GetOpDefOutputArg(const void* op_def, int idx) {
		return ((OpDef*)op_def)->mutable_output_arg(idx);
	}

	const char* TFEX_GetOpDefArgDefName(const void* arg_def) {
		return ((::tensorflow::OpDef_ArgDef *)arg_def)->name().c_str();
	}

	const char* TFEX_GetOpDefArgDefDescription(const void* arg_def) {
		return ((::tensorflow::OpDef_ArgDef *)arg_def)->description().c_str();
	}

	int TFEX_GetOpDefArgDefDataType(const void* arg_def) {
		return ((::tensorflow::OpDef_ArgDef *)arg_def)->type();
	}

	const char* TFEX_GetOpDefArgDefTypeAttr(const void* arg_def) {
		return ((::tensorflow::OpDef_ArgDef *)arg_def)->type_attr().c_str();
	}

	int   TFEX_GetOpDefAttrCount(const void* op_def) {
		return ((OpDef*)op_def)->attr_size();
	}

	void* TFEX_GetOpDefAttr(const void* op_def, int idx) {
		return ((OpDef*)op_def)->mutable_attr(idx);
	}

	const char* TFEX_GetOpDefAttrName(const void* op_def_attr) {
		return ((::tensorflow::OpDef_AttrDef *)op_def_attr)->name().c_str();
	}

	const char* TFEX_GetOpDefAttrDescription(const void* op_def_attr) {
		return ((::tensorflow::OpDef_AttrDef *)op_def_attr)->description().c_str();
	}

	void* TFEX_GetOpDefAttrMetadata(const void* op_def_attr) {
		::google::protobuf::Metadata metadata;
		metadata = ((::tensorflow::OpDef_AttrDef *)op_def_attr)->GetMetadata();
		return (void *)&metadata;
	}

	const char* TFEX_GetOpDefAttrType(const void* op_def_attr) {
		return ((::tensorflow::OpDef_AttrDef *)op_def_attr)->type().c_str();
	}

	void* TFEX_GetOpDefAttrDefaultValue(const void* op_def_attr) {
		return ((::tensorflow::OpDef_AttrDef *)op_def_attr)->mutable_default_value();
	}

    void* TFEX_AllocAttrValue(TF_Operation* oper, const char* attr_name,
                            TF_Status* s) {
		tensorflow::AttrValue* attr_value = nullptr;
		if (oper && attr_name) {
			TF_Buffer* buffer = TF_NewBuffer();
			TF_OperationGetAttrValueProto(oper, attr_name, buffer, s);
			if (TF_GetCode(s) == TF_OK) {
				attr_value = new tensorflow::AttrValue();
				attr_value->ParseFromArray(buffer->data, buffer->length);
			}
			else {
				return nullptr;
			}
			TF_DeleteBuffer(buffer);
		}
		return (void*)attr_value;
	}
	
	int   TFEX_GetAttrValueCase(const void* attr_value) {
		return ((::tensorflow::AttrValue *)attr_value)->value_case();
	}
	
	int   TFEX_GetAttrValueType(const void* attr_value) {
		return ((::tensorflow::AttrValue *)attr_value)->type();
	}

	int   TFEX_AttrValueHasTensor(const void* attr_value) {
		return (int)((::tensorflow::AttrValue *)attr_value)->has_tensor();
	}

	void* TFEX_GetAttrValue_tensor(const void* attr_value) {
		return (void*)((::tensorflow::AttrValue *)attr_value)->mutable_tensor();
	}

	const char* TFEX_GetAttrValue_s(const void* attr_value) {
        if (((::tensorflow::AttrValue *)attr_value)->value_case() == ::tensorflow::AttrValue::kS) {
		  return ((::tensorflow::AttrValue *)attr_value)->s().c_str();
        }
		else {
		  return nullptr;
		}
	}

	int64_t TFEX_GetAttrValue_i(const void* attr_value) {
        if (((::tensorflow::AttrValue *)attr_value)->value_case() == ::tensorflow::AttrValue::kI) {
		  return ((::tensorflow::AttrValue *)attr_value)->i();
        }
		else {
		  return 0;
		}
	}
	
	float TFEX_GetAttrValue_f(const void* attr_value) {
        if (((::tensorflow::AttrValue *)attr_value)->value_case() == ::tensorflow::AttrValue::kF) {
		  return ((::tensorflow::AttrValue *)attr_value)->f();
        }
		else {
		  return 0.0;
		}
	}
	
	void* TFEX_AllocGraphDefFromGraph(const void* graph) {
		if (graph) {
		   GraphDef* graph_def = new GraphDef();
		   TF_Graph* pGraph = (TF_Graph*)graph;
		   mutex_lock l(pGraph->mu);
		   pGraph->graph.ToGraphDef(graph_def);
		   return (void*)graph_def;
		}
		else {
		   return nullptr;	
		}
	}

	void* TFEX_AddNodeDefToGraphDef(const void* graph_def) {
		if (graph_def) {
			GraphDef* pGraphDef = (GraphDef*)graph_def;
			return (void*)pGraphDef->add_node();
		}
		else {
			return nullptr;
		}
	}
	
	int   TFEX_GetNodeDefsCount(const void* graph_def) {
		if (graph_def) {
	       GraphDef* pDef = (GraphDef*)graph_def;
		   return pDef->node_size();
		}
		else {
		   return -1;	
		}
	}
	
	void* TFEX_GetNodeDef(const void* graph_def, int idx) {
		if (graph_def) {
	       GraphDef* pDef = (GraphDef*)graph_def;
		   return (void*)pDef->mutable_node(idx);
		}
		else {
		   return nullptr;	
		}
	}

	const char* TFEX_AllocGraphDefDebugString(const void* graph_def) {
		if (graph_def) {
			GraphDef* pGraphDef = (GraphDef*)graph_def;
			std::string *s = new std::string(pGraphDef->DebugString());
			return s->c_str();
		}
		else {
			return nullptr;
		}
	}

	const char* TFEX_AllocNodeDefDebugString(const void* node_def) {
		if (node_def) {
			NodeDef* pDef = (NodeDef*)node_def;
			std::string *s = new std::string(pDef->DebugString());
			return s->c_str();
		}
		else {
			return nullptr;
		}
	}

	void TFEX_DeleteDebugString(const char* debug_str) {
		if (debug_str) {
			delete debug_str;
		}
	}

	const char* TFEX_GetNodeDefOp(const void* node_def) {
		if (node_def) {
	       NodeDef* pDef = (NodeDef*)node_def;
		   return pDef->op().c_str();
		}
		else {
		   return nullptr;	
		}
	}

    const char* TFEX_GetNodeDefName(const void* node_def) {
		if (node_def) {
	       NodeDef* pDef = (NodeDef*)node_def;
		   return pDef->name().c_str();
		}
		else {
		   return nullptr;	
		}
	}

    int TFEX_GetNodeDefInputCount(const void* node_def) {
		if (node_def) {
	       NodeDef* pDef = (NodeDef*)node_def;
		   return pDef->input_size();
		}
		else {
		   return -1;	
		}
	}

	const char* TFEX_GetNodeDefInput(const void* node_def, int idx) {
		if (node_def) {
			NodeDef* pDef = (NodeDef*)node_def;
			return pDef->input(idx).c_str();
		}
		else {
			return nullptr;
		}
	}

    void* TFEX_GetNodeDefAttrMap(const void* node_def) {
		if (node_def) {
			NodeDef* pDef = (NodeDef*)node_def;
			return (void*)&(pDef->attr());
		}
		else {
			return nullptr;
		}
	}

	/*
	int TFEX_GetAttrMapCount(const void* map) {
		if (map) {
			::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >* pAttrMap =
				  (::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >*)map;
			return pAttrMap->size();
		}
		else {
			return -1;
		}
	}

	void* TFEX_GetAttrMapIterator(const void* map) {
		if (map) {
			::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >* pAttrMap =
				(::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >*)map;
			::google::protobuf::Map<::std::string, ::tensorflow::AttrValue>::iterator* pIt =
				new ::google::protobuf::Map<::std::string, ::tensorflow::AttrValue>::iterator(pAttrMap->begin());
			return pIt;
		}
		else {
			return nullptr;
		}
	}

	void TFEX_DeleteAttrMapIterator(const void* it) {
		if (it) {
			::google::protobuf::Map<::std::string, ::tensorflow::AttrValue>::iterator* pIt =
				(::google::protobuf::Map<::std::string, ::tensorflow::AttrValue>::iterator*)it;
		}
	}

	void* TFEX_AttrMapIteratorNext(const void* map, const void* it) {
		if (map && it) {
			::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >* pAttrMap =
				(::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >*)map;
			::google::protobuf::Map<::std::string, ::tensorflow::AttrValue>::iterator* pIt =
				(::google::protobuf::Map<::std::string, ::tensorflow::AttrValue>::iterator*)it;
			if (*pIt != pAttrMap->end()) {
    			(*pIt)++;
				return pIt;
			}
			else {
				return nullptr;
			}
		}
		else {
			return nullptr;
		}
	}
    */

	const void* TFEX_GetAttrMapAt(const void* map, const char* key) {
		if (map) {
			::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >* pAttrMap =
				(::google::protobuf::Map< ::std::string, ::tensorflow::AttrValue >*)map;
			return (void*)&(pAttrMap->at(key));
		}
		else {
			return nullptr;
		}
	}


	void* TFEX_GetSignatureDefMapFromMetaGraphDef(const void* metagraph_def) {
		if (metagraph_def) {
			tensorflow::MetaGraphDef* metagraphdef = (tensorflow::MetaGraphDef*)metagraph_def;
			return (void*)metagraphdef->mutable_signature_def();
		}
		else {
			return nullptr;
		}
	}

	void* TFEX_GetSignatureDefFromMap(const void* signature_def_map, const char* key) {
		if (signature_def_map) {
			::google::protobuf::Map< ::std::string, ::tensorflow::SignatureDef >* signaturedefmap =
				(::google::protobuf::Map< ::std::string, ::tensorflow::SignatureDef >*)signature_def_map;
			::std::string keystr = key;
			::tensorflow::SignatureDef* signature_def = &(signaturedefmap->at(keystr));
			return (void*)signature_def;
		}
		else {
			return nullptr;
		}
	}

	const char* TFEX_GetInputNameFromSignatureDef(const void* signature_def) {
		if (signature_def) {
			::tensorflow::SignatureDef* signaturedef = (::tensorflow::SignatureDef*)signature_def;
			return signaturedef->inputs().at(tensorflow::kRegressInputs).name().c_str();
		}
		else {
			return nullptr;
		}
	}

	const char* TFEX_GetOutputNameFromSignatureDef(const void* signature_def) {
		if (signature_def) {
			::tensorflow::SignatureDef* signaturedef = (::tensorflow::SignatureDef*)signature_def;
			return signaturedef->outputs().at(tensorflow::kRegressOutputs).name().c_str();
		}
		else {
			return nullptr;
		}
	}


	int TFEX_TensorIntValCount(const void* tensor) {
		if (tensor) {
			::tensorflow::TensorProto* pTensor = (::tensorflow::TensorProto*)tensor;
			return pTensor->int_val_size();
		}
		else {
			return -1;
		}
	}

	int TFEX_TensorIntVal(const void* tensor, int idx) {
		if (tensor) {
			::tensorflow::TensorProto* pTensor = (::tensorflow::TensorProto*)tensor;
			return (int)pTensor->int_val(idx);
		}
		else {
			return -1;
		}
	}

	int TFEX_ParseTensorName(const char* name, char* first, int* first_len) {
		if (name) {
			std::string str_name(name);
			tensorflow::TensorId tensor_id = tensorflow::ParseTensorName(str_name);
			std::string& tensor_id_first = tensor_id.first.ToString();
			*first_len = tensor_id_first.size();
			memcpy(first, tensor_id_first.c_str(), *first_len);
			first[*first_len] = '\0';
			return tensor_id.second;
		}
		else {
			return -1;
		}
	}

	const char* TFEX_ColocationAttrName() {
		return tensorflow::kColocationAttrName;
	}


	const char* TFEX_ColocationGroupPrefix() {
		return tensorflow::kColocationGroupPrefix;
	}

	const char* TFEX_SavedModelTagServe() {
		return tensorflow::kSavedModelTagServe;
	}

	const char* TFEX_SavedModelTagTrain() {
		return tensorflow::kSavedModelTagTrain;
	}

//----------------------------------------------------------------------------------
//------------------------ Register Ops --------------------------------------------
//----------------------------------------------------------------------------------

// REGISTER_OP for CApiTestAttributesTest test cases.
// Registers two ops, each with a single attribute called 'v'.
// The attribute in one op will have a type 'type', the other
// will have list(type).
#define ATTR_TEST_REGISTER_OP(type)                           \
  REGISTER_OP("CApiAttributesTestOp" #type)                   \
      .Attr("v: " #type)                                      \
      .SetShapeFn(tensorflow::shape_inference::UnknownShape); \
  REGISTER_OP("CApiAttributesTestOpList" #type)               \
      .Attr("v: list(" #type ")")                             \
      .SetShapeFn(tensorflow::shape_inference::UnknownShape)

	int TFEX_RegisterOpsForTesting() {
		int n = 0;
		REGISTER_OP("TestOpWithNoGradient")
			.Input("x: T")
			.Output("y: T")
			.Attr("T: {float, double}")
			.Doc(R"doc(
Test op with no grad registered.

x: input
y: output
)doc")
.SetShapeFn(tensorflow::shape_inference::UnknownShape);
		n++;
		ATTR_TEST_REGISTER_OP(string);
		n++;
		ATTR_TEST_REGISTER_OP(int);
		n++;
		ATTR_TEST_REGISTER_OP(float);
		n++;
		ATTR_TEST_REGISTER_OP(bool);
		n++;
		ATTR_TEST_REGISTER_OP(type);
		n++;
		ATTR_TEST_REGISTER_OP(shape);
		n++;
		ATTR_TEST_REGISTER_OP(tensor);
		n++;
		return n;
	}
#undef ATTR_TEST_REGISTER_OP


//----------------------------------------------------------------------------------
//------------------------ Special Tests -------------------------------------------
//----------------------------------------------------------------------------------

	int TFEX_SpecialTest1(char* protbuf, size_t protbuf_len, void(*prot_callback)(char* buf, size_t len)) {
		//>>>
		std::stringstream ss;
		ss << "TFEX_SpecialTest1";
		std::string& str = ss.str();
		int len = str.size();
		memcpy(protbuf, str.c_str(), len);
		protbuf[len] = '\0';
		(*prot_callback)(protbuf, len);
        //<<<
	}

	int TFEX_SpecialTest2(char* protbuf, size_t protbuf_len, void(*prot_callback)(char* buf, size_t len)) {
		std::stringstream ss;
		ss << "TFEX_SpecialTest2";

		//
		std::string& str = ss.str();
		int len = str.size();
		memcpy(protbuf, str.c_str(), len);
		protbuf[len] = '\0';
		(*prot_callback)(protbuf, len);
	}

}  // end extern "C"
