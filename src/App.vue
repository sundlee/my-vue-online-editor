<template>
  <div id="app">
    <nav-bar />
    <div class="split">
      <div id="split-0" class="content">
        <b-card class="aside">
          <template #header>
            <div class="explorer-header">
              <h6 class="mb-0">EXPLORER</h6>
              <b-button
                variant="custom-4"
                size="sm"
                @click="addNode"
              >
                <b-icon icon="plus"></b-icon>
              </b-button>
            </div>
          </template>
          <!-- <button
            class="vtl-btn"
            @click="addNode"
          >
            Add Node
          </button> -->
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
            <!-- <template v-slot:leafNameDisplay="slotProps">
              <span>
                {{ slotProps.model.name }} <span class="muted">#{{ slotProps.model.id }}</span>
              </span>
            </template> -->
            <!-- <span class="icon" slot="addTreeNodeIcon">📂</span>
            <span class="icon" slot="addLeafNodeIcon">＋</span>
            <span class="icon" slot="editNodeIcon">📃</span>
            <span class="icon" slot="delNodeIcon">✂️</span>
            <span class="icon" slot="leafNodeIcon">🍃</span>
            <span class="icon" slot="treeNodeIcon">🌲</span> -->
          </vue-tree-list>
          <!-- <button @click="getNewTree">Get new tree</button>
          <pre>
            {{newTree}}
          </pre> -->
        </b-card>
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
import { VueTreeList, Tree, TreeNode } from '@/components/vtl/'
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
          // pid: 0,
          // dragDisabled: true,
          // addTreeNodeDisabled: true,
          // addLeafNodeDisabled: true,
          // editNodeDisabled: true,
          // delNodeDisabled: true,
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
          // disabled: true
        },
        {
          name: 'Node 3',
          id: 4,
          pid: 0
        },
        {
          name: 'Node 4',
          id: 5,
          pid: 0,
          children: [
            {
              name: 'Node 4-1',
              id: 6,
              isLeaf: true,
              pid: 0
            },
            {
              name: 'Node 4-2',
              id: 7,
              isLeaf: true,
              pid: 7
            }
          ]
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
      console.log('onDel: ', node)
      node.remove()
    },
    onChangeName(params) {
      console.log('onChangeName: ', params)
    },
    onAddNode(params) {
      console.log('onAddNode: ', params)
    },
    onClick(params) {
      console.log('onClick: ', params)
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

<style lang="scss">
.split {
  display: flex;
  flex-direction: row;
  .content {
    // padding: 8px;
    border: 1px solid #c0c0c0;
    box-shadow: inset 0 1px 2px #e4e4e4;
    background-color: #fff;
    
    /* height: 500px; */
    .aside {
      margin: 0;
      height: 100%;
      .explorer-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
      }
    }
  }
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
.vtl-btn {
  font-size: 13px;
}
.icon {
  &:hover {
    cursor: pointer;
    // background-color: red;
  }
}
.muted {
  color: gray;
  font-size: 80%;
}
</style>
