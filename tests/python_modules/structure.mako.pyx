from structure cimport init_structure, dealloc_structure
from cpython.mem cimport PyMem_Malloc, PyMem_Free

<%
    properties =  {
         'meaning_of_life': {
             'get': "meaning_of_life",
             'set': "meaning_of_life = int(value)",
         },
         'message': {
             'get': "message"
         }
    }
%>

cdef class Structure:
    """ A useless class """
    def __cinit__(self):
        self.cdata = <CStructure*> PyMem_Malloc(sizeof(CStructure))
        if not self.cdata:
            raise MemoryError("Could not allocate C object")
        init_structure(self.cdata)
    def __dealloc__(self):
        dealloc_structure(self.cdata)
        PyMem_Free(self.cdata)

% for name, impl in properties.iteritems():
    property ${name}:
        def __get__(self):
            return self.cdata.${impl['get']}
    % if 'set' in impl:
        def __set__(self, value):
            self.cdata.${impl['set']}
    % endif
% endfor
