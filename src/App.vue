<template>
  <div id="app" @click="contextMenuIsVisible = false">
    <nav-bar />
    <div class="last-event row">
      Last event: {{ lastEvent }}
    </div>
    <div class="split">
      <div id="split-0" class="content">
        <b-card class="aside">
          <template #header>
            <div class="explorer-header">
              <h6 class="mb-0">EXPLORER</h6>
              <b-dropdown
                ref="plusDropdownBtn"
                right
                variant="link"
                class="plus-button"
                no-caret
              >
                <template #button-content>
                  <span class="btn-more text-dark">
                    <b-icon icon="plus"></b-icon>
                  </span>
                </template>
                <b-dropdown-item-button @click.prevent.stop="addFile">
                  새 파일
                </b-dropdown-item-button>
                <b-dropdown-item-button @click.prevent.stop="addFolder">
                  새 폴더
                </b-dropdown-item-button>
                <b-dropdown-divider></b-dropdown-divider>
                <b-dropdown-item-button @click.prevent.stop="importZip">
                  zip 파일
                </b-dropdown-item-button>
              </b-dropdown>
            </div>
          </template>
<!-- -->
          <vue-file-tree 
            id="file-tree"
            ref="filetree"
            class="column"
            @nodeClick="nodeClick"
            @nodeDoubleClick="nodeDoubleClick"
            @nodeDrop="nodeDrop"
          >
            <template slot="context-menu">
              <div @click="doDashboard">Dashboard</div>
              <div @click="doCustomers">Customers</div>
            </template>
          </vue-file-tree>
<!-- -->
          <!-- <sl-vue-tree
            v-model="nodes"
            ref="slVueTree"
            :allow-multiselect="false"
            @select="nodeSelected"
            @drop="nodeDropped"
            @toggle="nodeToggled"
            @nodecontextmenu="showContextMenu"
          >
            <template slot="title" slot-scope="{ node }">
              <span class="item-icon">
                <i class="fa fa-file" v-if="node.isLeaf"></i>
                <i class="fa fa-folder" v-if="!node.isLeaf"></i>
              </span>
              {{ node.title }}
            </template>

            <template slot="toggle" slot-scope="{ node }">
              <span v-if="!node.isLeaf">
                <i v-if="node.isExpanded" class="fa fa-chevron-down"></i>
                <i v-if="!node.isExpanded" class="fa fa-chevron-right"></i>
              </span>
            </template>

            <template slot="draginfo">
              {{ selectedNodesTitle }}
            </template>
          </sl-vue-tree> -->
<!-- -->
        </b-card>
      </div>
      <div id="split-1" class="content">
        <div class="json-preview">
          <pre>{{ JSON.stringify(nodes, null, 4)}}</pre>
        </div>
        <div class="contextmenu" ref="contextmenu" v-show="contextMenuIsVisible">
          <div @click="removeNode">Remove</div>
        </div>
        <!-- <codemirror
          ref="codemirror"
          :value="code"
          :options="cmOptions"
        /> -->
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Split from 'split.js';
import JSZip from 'jszip';
import { saveAs } from '@/utils/file-saver';
// import SlVueTree  from '@/components/sl-vue-tree/sl-vue-tree.vue';
import VueFileTree  from '@/components/vue-file-tree/vue-file-tree.vue';
// import { codemirror } from 'vue-codemirror';
import 'codemirror/lib/codemirror.css';
import 'codemirror/addon/lint/lint.css';
import 'codemirror/lib/codemirror';
import 'codemirror/mode/javascript/javascript';
import 'codemirror/mode/css/css';
import 'codemirror/addon/lint/json-lint';
import 'codemirror/addon/selection/active-line';
import NavBar from './components/NavBar.vue';

export default {
  name: 'App',
  components: {
    NavBar,
    // SlVueTree,
    VueFileTree,
    // codemirror,
  },
  data() {
    return {
      nodes: [
        { title: 'Item1', isLeaf: true },
        { title: 'Item2', isLeaf: true },
        { title: 'Folder1' },
        {
          title: 'Folder2', isExpanded: true, children: [
            { title: 'Item3', isLeaf: true },
            { title: 'Item4', isLeaf: true },
            {
              title: 'Folder3', children: [
                { title: 'Item5', isLeaf: true }
              ]
            }
          ]
        },
      ],
      selectedNodesTitle: '',
      contextMenuIsVisible: false,
      lastEvent: 'No last event',

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
      gutterSize: 7,
      minSize: [150, 300],
      maxSize: [500, Infinity],
      cursor: 'col-resize',
    };
  },
  mounted() {
    window.slVueTree = this.$refs.slVueTree;

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

    this.$refs.filetree.addPathToTree('template\\index.js', {}, false);
    this.$refs.filetree.addPathToTree('template\\log.png', {}, false);
    this.$refs.filetree.addPathToTree('src\\handler.py', {}, false);
    this.$refs.filetree.addPathToTree('package.json', {}, false);
    this.$refs.filetree.addPathToTree('README.md', {}, false);
    this.$refs.filetree.addPathToTree('index.ejs', {}, false);
  },
  methods: {
    // onChangeName(params) {
    //   console.log('onChangeName: ', params);
    // },
    // onAddNode(params) {
    //   console.log('onAddNode: ', params);
    // },
    // onClick(params) {
    //   console.log('onClick: ', params);
    // },
    addFile() {
      console.log('addFile is called.');
    },
    addFolder() {
      console.log('addFolder is called.');
    },
    importZip() {
      console.log('importZip is called.');
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
    },
    handleFileUpload() {
      this.files = [];
      this.fileNames = [];
      this.selectedFile = this.$refs.file.files[0];
      // console.log(this.selectedFile.name);

      var new_zip = new JSZip();
      new_zip.loadAsync(this.selectedFile)
        .then((zip) => {
          this.rawFileNames = Object.keys(zip.files);
          console.log(this.rawFileNames);
          
          const promiseArray = [];
          this.rawFileNames.forEach((file) => {
            if (!file.endsWith('/')) {
              this.fileNames.push(file);
              promiseArray.push(zip.file(file).async('uint8array'));
            }
          });
          Promise.all(promiseArray)
            .then((data) => {
              // console.log(data);
              this.fileNames.forEach((file, idx) => {
                this.files.push({
                  name: file,
                  content: data[idx],
                });
              });
              // console.log(`files: ${JSON.stringify(this.files, null, 4)}`);
            });
        });
    },
    handleClickDownloadBtn() {
      var zip = new JSZip();

      this.files.forEach((file) => {
        zip.file(file.name, file.content);
      });

      zip.generateAsync({ type: "blob" }, function updateCallback(metadata) {
          var msg = "progression: " + metadata.percent.toFixed(2) + " %";
          if(metadata.currentFile) {
              msg += ", current file = " + metadata.currentFile;
          }
          console.log(msg);
      })
      .then(function callback(blob) {
          saveAs(blob, "example.zip");

          console.log("done !");
      }, function (e) {
          console.log(e);
      });
    },
    toggleVisibility: function (event, node) {
      const slVueTree = this.$refs.slVueTree;
      event.stopPropagation();
      const visible = !node.data || node.data.visible !== false;
      slVueTree.updateNode(node.path, {data: { visible: !visible}});
      this.lastEvent = `Node ${node.title} is ${ visible ? 'visible' : 'invisible'} now`;
    },
    nodeSelected(nodes, event) {
      console.log(nodes);
      this.selectedNodesTitle = nodes.map(node => node.title).join(', ');
      this.lastEvent = `Select nodes: ${this.selectedNodesTitle}`;
    },
    nodeToggled(node, event) {
      this.lastEvent = `Node ${node.title} is ${ node.isExpanded ? 'expanded' : 'collapsed'}`;
    },
    nodeDropped(nodes, position, event) {
      this.lastEvent = `Nodes: ${nodes.map(node => node.title).join(', ')} are dropped ${position.placement} ${position.node.title}`;
    },
    showContextMenu(node, event) {
      event.preventDefault();
      this.contextMenuIsVisible = true;
      const $contextMenu = this.$refs.contextmenu;
      $contextMenu.style.left = event.clientX + 'px';
      $contextMenu.style.top = event.clientY + 'px';
    },
    removeNode() {
      this.contextMenuIsVisible = false;
      const $slVueTree = this.$refs.slVueTree;
      const paths = $slVueTree.getSelected().map(node => node.path);
      $slVueTree.remove(paths);
    },
        nodeClick(event, node) {
      // console.log(`nodeClick ${util.inspect(node)}`);
      console.log('nodeClick: ', node);
    },
    nodeDoubleClick(node) {
      // console.log(`nodeDoubleClick ${util.inspect(node)}`);
      console.log('nodeDoubleClick: ', node);
    },
    nodeDrop(node) {
      // console.log(`nodeDrop ${util.inspect(node)}`);
      console.log('nodeDrop: ', node);
    },
    doCustomers() {
      console.log(`doCustomers`);
      this.$refs.filetree.contextMenuIsVisible = false;
    },
    doDashboard() {
      console.log(`doDashboard`);
      this.$refs.filetree.contextMenuIsVisible = false;
    },
  },  
};
</script>

<style src="@/components/sl-vue-tree/sl-vue-tree-code.css"></style>
<style lang="scss">
body {
  background: #050d12;
  font-family: Arial;
  color: rgba(255, 255, 255, 0.5);
}

a {
  color: #bbb;
}

.row {
  display: flex;
  margin-bottom: 10px;
}

.contextmenu {
  position: absolute;
  background-color: white;
  color: black;
  border-radius: 2px;
  cursor: pointer;
}

.contextmenu > div {
  padding: 10px;
}

.contextmenu > div:hover {
  background-color: rgba(100, 100, 255, 0.5);
}


.last-event {
  color: white;
  background-color: rgba(100, 100, 255, 0.5);
  padding: 10px;
  border-radius: 2px;
}

.tree-container {
  flex-grow: 1;
}

.sl-vue-tree.sl-vue-tree-root {
  flex-grow: 1;
  overflow-x: hidden;
  overflow-y: auto;
  height: 300px;
}


.json-preview {
  // flex-grow: 1;
  // margin-left: 10px;
  // background-color: #13242d;
  // border: 1px solid black;
  padding: 10px;
  font-size: 13px;
}

.item-icon {
  display: inline-block;
  text-align: left;
  width: 20px;
}

.split {
  display: flex;
  flex-direction: row;
  .content {
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
        .plus-button {
          display: flex;
          justify-content: center;
          align-items: center;
          .dropdown-menu.show {
            width: 110px;
            left: -16px !important;
            font-size: 13px;
          }
        }
      }
    }
    .card-body {
      padding: 0;
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
