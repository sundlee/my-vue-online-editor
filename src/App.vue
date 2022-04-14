<template>
  <div id="app">
    <nav-bar />
    <div class="last-event row">
      <!-- Last event: {{ lastEvent }} -->
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

          <vue-file-tree 
            id="file-tree"
            ref="filetree"
            class="column"
            @nodeClick="nodeClick"
            @nodeDoubleClick="nodeDoubleClick"
            @nodeDrop="nodeDrop"
          >
            <!-- <template slot="context-menu">
              <div @click="doDashboard">Dashboard</div>
              <div @click="doCustomers">Customers</div>
            </template> -->
          </vue-file-tree>

        </b-card>
      </div>
      <div id="split-1" class="content">
        <codemirror
          ref="codemirror"
          :value="selectedNode.data.content"
          :options="cmOptions"
        />
      </div>
    </div>

    <b-modal
      ref="inputSelectedFileNameModal"
      title="파일 추가"
      @ok="handleOkSelectedInputFileName"
    >
      <div class="d-block text-center">
        <p>추가할 파일 이름을 입력해주세요.</p>
      </div>
      <b-form-input
        v-model="selectedInputFileName"
        placeholder="Enter file name"
      ></b-form-input>
    </b-modal>
  </div>
</template>

<script>
// import util from 'util';
import Split from 'split.js';
import JSZip from 'jszip';
import { saveAs } from '@/utils/file-saver';
import VueFileTree  from '@/components/vue-file-tree/vue-file-tree.vue';
import { codemirror } from 'vue-codemirror';
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
    VueFileTree,
    codemirror,
  },
  data() {
    return {
      selectedZipFile: null,
      selectedInputFileName: '',
      selectedNode: { data: { content: '' } },

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
      handlerContent: '"use strict";\n\nmodule.exports = async (context, callback) => {\n    return {status: "handlerJs"};\n}',
      handlerContent2: '"use strict";\n\nmodule.exports = async (context, callback) => {\n    return {status: "handlerJs2222"};\n}',
      handlerContentPy: '"use strict";\n\nmodule.exports = async (context, callback) => {\n    return {status: "handlerPy"};\n}',
      packageContent: '{\n  "name": "examplejs",\n  "version": "0.1.0",\n  "private": true,\n  "scripts": {\n    "serve": "vue-cli-service serve",\n    "build": "vue-cli-service build",\n    "lint": "vue-cli-service lint"\n  }\n}',
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

    // this.$refs.filetree.addPathToTree('_TREE_ROOT_NODE_/template/index.js', {}, false);
    // this.$refs.filetree.addPathToTree('_TREE_ROOT_NODE_/template/logo.png', {}, false);
    this.$refs.filetree.addPathToTree('_TREE_ROOT_NODE_/src/handler.py', this.handlerContentPy, false);
    this.$refs.filetree.addPathToTree('_TREE_ROOT_NODE_/package.json', this.packageContent, false);
    // this.$refs.filetree.addPathToTree('_TREE_ROOT_NODE_/README.md', {}, false);
    this.$refs.filetree.addPathToTree('_TREE_ROOT_NODE_/handler.js', this.handlerContent, false);

    this.setDefaultFile();
  },
  methods: {
    setDefaultFile() {
      this.$refs.filetree.setDefaultNode();
      const node = this.$refs.filetree.getSelected();
      this.$nextTick(() => {
        console.log('setDefaultFile() - node: ', node);
        this.selectedNode = node[0];
      });
    },
    addFile() {
      console.log('pathname: ', this.selectedNode);
      this.$refs.inputSelectedFileNameModal.show();
    },
    handleOkSelectedInputFileName(e) {
      e.preventDefault();
      
      console.log('selectedInputFileName: ', this.selectedInputFileName);
      this.$nextTick(() => {
        this.$refs.inputSelectedFileNameModal.hide();
      });

      this.$refs.filetree.addPathToTree('_TREE_ROOT_NODE_/handler22.js', this.handlerContent2, false);

    },
    addFolder() {
      console.log('addFolder is called.');
    },
    importZip() {
      console.log('importZip is called.');
    },
    // removeNode() {
    //   const $slVueTree = this.$refs.slVueTree;
    //   const paths = $slVueTree.getSelected().map(node => node.path);
    //   $slVueTree.remove(paths);
    // },
    nodeClick(event, node) {
      // console.log(`addPathToTree ${util.inspect(process)}`);
      // console.log(`nodeClick ${util.inspect(node)}`);
      // console.log(`nodeClick node.isSelected: ${JSON.stringify(node.isSelected, null, 4)}`);

      this.selectedNode = node;
      // console.log('nodeClick: ', node.title);
    },
    nodeDoubleClick(node) {
      // console.log(`nodeDoubleClick ${util.inspect(node)}`);
      console.log('nodeDoubleClick: ', node.title);
    },
    nodeDrop(node) {
      // console.log(`nodeDrop ${util.inspect(node)}`);
      console.log('nodeDrop: ', node);
    },
    // doCustomers() {
    //   console.log(`doCustomers`);
    //   this.$refs.filetree.contextMenuIsVisible = false;
    // },
    // doDashboard() {
    //   console.log(`doDashboard`);
    //   this.$refs.filetree.contextMenuIsVisible = false;
    // },
    handleFileUpload() {
      this.files = [];
      this.fileNames = [];
      this.selectedZipFile = this.$refs.file.files[0];
      // console.log(this.selectedZipFile.name);

      var new_zip = new JSZip();
      new_zip.loadAsync(this.selectedZipFile)
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
  // color: white;
  // background-color: rgba(100, 100, 255, 0.5);
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
