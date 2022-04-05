<template>
  <div id="app">
    <nav-bar />
    <div class="split">
      <div id="split-0" class="content">
        <button @click="addNode">Add Node</button>
        <vue-tree-list
          @click="onClick"
          @change-name="onChangeName"
          @delete-node="onDel"
          @add-node="onAddNode"
          :model="data"
          default-tree-node-name="new node"
          default-leaf-node-name="new leaf"
          v-bind:default-expanded="false"
        >
          <template v-slot:leafNameDisplay="slotProps">
            <span>
              {{ slotProps.model.name }} <span class="muted">#{{ slotProps.model.id }}</span>
            </span>
          </template>
          <span class="icon" slot="addTreeNodeIcon">📂</span>
          <span class="icon" slot="addLeafNodeIcon">＋</span>
          <span class="icon" slot="editNodeIcon">📃</span>
          <span class="icon" slot="delNodeIcon">✂️</span>
          <span class="icon" slot="leafNodeIcon">🍃</span>
          <span class="icon" slot="treeNodeIcon">🌲</span>
        </vue-tree-list>
        <!-- <button @click="getNewTree">Get new tree</button>
        <pre>
          {{newTree}}
        </pre> -->
      </div>
      <div id="split-1" class="content">
        <codemirror
          ref="codemirror"
          :value="code"
          :options="cmOptions"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Split from 'split.js';
import NavBar from './components/NavBar.vue';
import { VueTreeList, Tree, TreeNode } from 'vue-tree-list'
import { codemirror } from 'vue-codemirror';
import 'codemirror/lib/codemirror.css';
import 'codemirror/addon/lint/lint.css';
import 'codemirror/lib/codemirror';
import 'codemirror/mode/javascript/javascript';
import 'codemirror/mode/css/css';
import 'codemirror/addon/lint/json-lint';
import 'codemirror/addon/selection/active-line';

export default {
  name: 'App',
  components: {
    NavBar,
    VueTreeList,
    codemirror,
  },
  data() {
    return {
      newTree: {},
      data: new Tree([
        {
          name: 'Node 1',
          id: 1,
          pid: 0,
          dragDisabled: true,
          addTreeNodeDisabled: true,
          addLeafNodeDisabled: true,
          editNodeDisabled: true,
          delNodeDisabled: true,
          children: [
            {
              name: 'Node 1-2',
              id: 2,
              isLeaf: true,
              pid: 1
            }
          ]
        },
        {
          name: 'Node 2',
          id: 3,
          pid: 0,
          disabled: true
        },
        {
          name: 'Node 3',
          id: 4,
          pid: 0
        }
      ]),

      code: 'console.log(\'Hello World 1!\');\n\nconsole.log(\'Hello World 2!\');\n',
      cmOptions: {
        tabSize: 2,
        autofocus: true,
        mode: 'javascript',
        styleActiveLine: true,
        lineWrapping: true,
        lineNumbers: true,
        line: true,
        gutters: ['CodeMirror-lint-markers'],
        height: 'auto',
        lint: true,
        matchBrackets: true,
        autoCloseBrackets: true,
      },
      sizes: [20, 80],
      gutterSize: 10,
      minSize: [150, 300],
      maxSize: [500, Infinity],
      cursor: 'col-resize',
    };
  },
  mounted() {
    let sizes = localStorage.getItem('split-sizes')
    if (sizes) {
      sizes = JSON.parse(sizes);
    } else {
      sizes = [20, 80];
    }
    this.sizes = sizes;

    Split(['#split-0', '#split-1'], {
      sizes,
      gutterSize: this.gutterSize,
      minSize: this.minSize,
      maxSize: this.maxSize,
      cursor: this.cursor,
      onDragEnd: function (sizes) {
        localStorage.setItem('split-sizes', JSON.stringify(sizes))
      },
    });
  },
  methods: {
    onDel(node) {
      console.log(node)
      node.remove()
    },

    onChangeName(params) {
      console.log(params)
    },

    onAddNode(params) {
      console.log(params)
    },

    onClick(params) {
      console.log(params)
    },

    addNode() {
      var node = new TreeNode({ name: 'new node', isLeaf: false })
      if (!this.data.children) this.data.children = []
      this.data.addChildren(node)
    },

    getNewTree() {
      var vm = this
      function _dfs(oldNode) {
        var newNode = {}

        for (var k in oldNode) {
          if (k !== 'children' && k !== 'parent') {
            newNode[k] = oldNode[k]
          }
        }

        if (oldNode.children && oldNode.children.length > 0) {
          newNode.children = []
          for (var i = 0, len = oldNode.children.length; i < len; i++) {
            newNode.children.push(_dfs(oldNode.children[i]))
          }
        }
        return newNode
      }

      vm.newTree = _dfs(vm.data);
    }
  },  
};
</script>

<style>
body {
  height: 100vh;
}
.content {
	padding: 8px;
	border: 1px solid #c0c0c0;
	box-shadow: inset 0 1px 2px #e4e4e4;
	background-color: #fff;
	
	/* height: 500px; */
}
.split {
  display: flex;
  flex-direction: row;
}
.gutter {
  background-color: #eee;
  background-repeat: no-repeat;
  background-position: 50%;
}
.gutter.gutter-horizontal {
  background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAeCAYAAADkftS9AAAAIklEQVQoU2M4c+bMfxAGAgYYmwGrIIiDjrELjpo5aiZeMwF+yNnOs5KSvgAAAABJRU5ErkJggg==');
  cursor: col-resize;
}
</style>
