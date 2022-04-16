<template>
    <span>
    <sl-vue-tree
            id="vue-file-tree"
            ref="slvuetree"
            :value="nodes"
            :allowMultiselect="false"
            @nodeclick="nodeClick"
            @nodedblclick="nodeDoubleClick"
            @select="nodeSelect"
            @toggle="nodeToggle"
            @drop="nodeDrop"
            @nodecontextmenu="nodeContextMenu"
            @externaldrop.prevent="onExternalDropHandler">

        <template slot="toggle" slot-scope="{ node }">
            <span v-if="!node.isLeaf">
                <font-awesome-icon 
                    icon="caret-right" 
                    v-if="!node.isExpanded"></font-awesome-icon>
                <font-awesome-icon 
                    icon="caret-down"
                    v-else-if="node.isExpanded"></font-awesome-icon>
            </span>
        </template>

        <template slot="title" slot-scope="{ node }">
            <font-awesome-icon 
                :icon="[ 'fab', 'js' ]" 
                v-if='node.data.type === "application/javascript"'></font-awesome-icon>
            <font-awesome-icon 
                icon="table" 
                v-else-if='node.data.type === "application/json"'></font-awesome-icon>
            <font-awesome-icon 
                icon="image" 
                v-else-if='node.data.type === "IMAGE"'></font-awesome-icon>
            <font-awesome-icon 
                icon="code" 
                v-else-if='node.data.type === "EJS"'></font-awesome-icon>
            <font-awesome-icon 
                :icon="[ 'fab', 'vuejs' ]" 
                v-else-if='node.data.type === "VUEJS"'></font-awesome-icon>
            <font-awesome-icon 
                icon="file" 
                v-else-if="node.isLeaf"></font-awesome-icon>
            {{ node.title === '_TREE_ROOT_NODE_' ? '/' : node.title }}</template>


        <template slot="sidebar" slot-scope="{ node }">
            <b-dropdown
                ref="plusDropdownBtn"
                right
                variant="link"
                class="plus-button"
                no-caret
                >
                <template #button-content>
                    <font-awesome-icon 
                        icon="ellipsis-h" 
                    />
                </template>
                <b-dropdown-item-button 
                    @click.prevent.stop="renameNode(node)"
                >
                    이름 변경
                </b-dropdown-item-button>
                <b-dropdown-item-button
                    @click.prevent.stop="removeNode(node)"
                >
                    삭제
                </b-dropdown-item-button>
            </b-dropdown>
        </template>
    </sl-vue-tree>


    <aside class="menu vue-file-tree-contextmenu" 
            ref="contextmenu" 
            v-show="contextMenuIsVisible">
        <slot name="context-menu"></slot>
    </aside>

    <b-modal
      ref="inputSelectedNameModal"
      title="이름 변경"
      @ok="handleOkSelectedInputName"
      @hidden="handleHiddenSelectedInputName"
    >
      <div class="d-block text-center">
        <p>새 이름을 입력해주세요.</p>
      </div>
      <b-form-input
        v-model="selectedInputName"
        placeholder="Enter folder name"
        autofocus
      ></b-form-input>
    </b-modal>

    </span>
</template>

<script>

import _ from 'lodash';
import path from 'path';
import util from 'util';
import splitter from './path-splitdirs';

import mime from 'mime';

import slVueTree from '@/components/sl-vue-tree/sl-vue-tree.vue';
// import '@/components/sl-vue-tree/sl-vue-tree-code.css';

import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faCaretRight, faCaretDown, faTable, faImage, faFile, faCircle, faCode, faEllipsisH
} from '@fortawesome/free-solid-svg-icons';
import { faJs, faVuejs } from '@fortawesome/free-brands-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

library.add(faJs, faVuejs, faCaretRight, faCaretDown, faTable, faImage, faFile, faCircle, faCode, faEllipsisH);


// TODO: Prevent dragging a file into a place where there's already one of the same name
//       In such a case ask the user what to do?  How?

// TODO: Support copy/paste

// TODO: Support delete

// TODO: move to own project -- publish as npm package

/* var nodes = [
    {title: 'Item1', isLeaf: true},
    {title: 'Item2', isLeaf: true, data: { visible: false }},
    {title: 'Folder1'},
    {
      title: 'Folder2', isExpanded: true, children: [
        {title: 'Item3', isLeaf: true},
        {title: 'Item4', isLeaf: true, data: { isModified: true }}
      ]
    }
]; */

export default {
    name: 'VueFileTree',
    data() {
        return {
            nodes: [],
            contextMenuIsVisible: false,

            selectedInputName: '',
            selectedNode: null,
        }
    },
    components: {
        'sl-vue-tree': slVueTree,
        'font-awesome-icon': FontAwesomeIcon
    },
    created() {
        /*
         * Derived from Buefy's b-dropdown
         * https://github.com/buefy/buefy/blob/dev/src/components/dropdown/Dropdown.vue
         */
        if (typeof window !== 'undefined') {
            document.addEventListener('click', this.clickedOutside)
        }
    },
    methods: {
        getSelected() {
            // console.log('getSelected: ', this.$refs.slvuetree.getSelected());
            return this.$refs.slvuetree.getSelected();
        },

        setDefaultNode() {
            // console.log('setDefaultNode() this.nodes[0]: ', this.nodes[0])
            this.nodes[0].isSelected = true;
        },
        
        nodeClick(node, event) {
            this.$emit('nodeClick', event, node);
        },
        nodeDoubleClick(node, event) {
            // console.log(`nodeDoubleClick ${node.title} ${node.data.type} isLeaf ${node.isLeaf} ${util.inspect(node)}`);
            if (!node.isLeaf) {
                this.$refs.slvuetree.onToggleHandler(event, node);
                return;
            }
            this.$emit('nodeDoubleClick', node);
        },
        nodeSelect(node) {
            // console.log(`nodeSelect ${util.inspect(node)}`);
        },
        nodeToggle(node) {
            // console.log(`nodeToggle ${util.inspect(node)}`);
        },
        nodeDrop(node) {
            // console.log(`nodeDrop ${util.inspect(node)}`);
            this.$emit('nodeDrop', node);
        },
        nodeContextMenu(node, event) {
            console.log(`nodeContextMenu ${util.inspect(node)}`);
            this.contextMenuIsVisible = true;
            const $contextMenu = this.$refs.contextmenu;
            $contextMenu.style.left = event.clientX + 'px';
            $contextMenu.style.top = event.clientY + 'px';
        },
        /**
         * Close dropdown if clicked outside.
         * Derived from Buefy's b-dropdown
         * https://github.com/buefy/buefy/blob/dev/src/components/dropdown/Dropdown.vue
         */
        clickedOutside(event) {
            if (!this.isInWhiteList(event.target)) this.contextMenuIsVisible = false;
        },
        // If the "clickOutside" is on a target where we should ignore the click
        // then we should ignore this.  
        // See: https://github.com/buefy/buefy/blob/dev/src/components/dropdown/Dropdown.vue
        isInWhiteList(el) { return false; },
        onExternalDropHandler(cursorPosition, event) {
            console.log('external drop', cursorPosition, util.inspect(event));
        },
        addPathToTree(fn, content, isDir) {
            // console.log(`addPathToTree() - ${fn} ${util.inspect(content)} ${isDir}`);
            // console.log(`addPathToTree ${util.inspect(process)}`);
            // console.log(util.inspect(path));
            fn = path.normalize(fn);
            // console.log(`addPathToTree NORMALIZED ${fn}`);
            const basenm = path.basename(fn);
            // console.log(`addPathToTree BASENAME ${basenm}`);

            const split = splitter(fn);
            // console.log(`addPathToTree split: ${JSON.stringify(split, null, 4)}`);

            // console.log(`addPathToTree dirs ${util.inspect(split)}`);
            let curnodes = this.nodes;
            for (let dir of split.dirs) {
                if (dir === '.') continue;
                let found = undefined;
                for (let cur of curnodes) {
                    if (cur.isLeaf === false && cur.title === dir) {
                        found = cur;
                        break;
                    }
                }
                if (!found) {
                    let newnode = {
                        title: dir, 
                        isLeaf: false,
                        children: [],
                        data: { 
                            type: "DIRECTORY",
                            pathname: split.dirs.slice(0, split.dirs.indexOf(dir) + 1).join('/'),
                            content: 'N/A',
                        }
                    };
                    // console.log(`addPathToTree() !found push newnode ${util.inspect(newnode)}`);
                    curnodes.push(newnode);
                    curnodes = newnode.children;
                } else {
                    curnodes = found.children;
                }
            }
            let newnode = {
                title: basenm, 
                isLeaf: !isDir, 
                data: { 
                    type: mime.getType(fn),
                    pathname: fn,
                    content
                }
            };
            if (!newnode.data.type) newnode.data.type = "text/plain";
            if (newnode.data.type.startsWith('image/')) newnode.data.type = "IMAGE";
            if (fn.endsWith('.ejs')) newnode.data.type = "EJS";
            if (fn.endsWith('.vue')) newnode.data.type = "VUEJS";
            if (!newnode.isLeaf) newnode.children = [];
            // console.log(`addPathToTree FINAL push newnode ${util.inspect(newnode)}`);
            curnodes.push(newnode);

            // console.log(`addPathToTree nodes 1: ${JSON.stringify(this.nodes[0].children, null, 4)}`);
            this.nodes[0].children = _.orderBy(this.nodes[0].children, ['isLeaf', 'title'], ['asc', 'asc']);
            // console.log(`addPathToTree nodes 2: ${JSON.stringify(this.nodes[0].children, null, 4)}`);
        },
        findNode(pathname) {
            const segments = pathname.split('/');

            let parentNode = this.nodes;
            let found = null;
            let flag = false;

            segments.forEach((segment) => {
                found = _.find(parentNode, { title: segment });
                if (found && !found.isLeaf) {
                    parentNode = found.children;
                } else if (found) {
                    console.log(`FOUND: ${found.title}`);
                    flag = true;
                } else {
                    console.error('NOT FOUND!!');
                }
            });

            return flag ? found : null;
        },
        renameNode(node) {
            this.selectedNode = node;
            this.$refs.inputSelectedNameModal.show();
        },

        handleOkSelectedInputName(e) {
            e.preventDefault();
            
            console.log('selectedInputName: ', this.selectedInputName);
            this.$nextTick(() => {
                const found = this.findNode(this.selectedNode.data.pathname);
                found.title = this.selectedInputName;
                this.$refs.inputSelectedNameModal.hide();
            });

        },
        handleHiddenSelectedInputName() {
            this.selectedInputName = '';
        },

        findParentNode(pathname) {
            let parentNode = this.nodes;
            let found = null;
            let flag = false;

            const segments = pathname.split('/');
            segments.forEach((segment) => {
                found = _.find(parentNode, { title: segment });
                console.log(`findParentNode() found: ${JSON.stringify(found, null, 4)}`);
                if (found && !found.isLeaf) {
                    console.log(`FOUND 111: ${found.title}`);
                    parentNode = found.children;
                } else if (found) {
                    console.log(`FOUND 222: ${found.title}`);
                    flag = true;
                } else {
                    console.error('NOT FOUND!!');
                }
            });

            return flag ? parentNode : null;
        },

        findParentDir(pathname) {
            let parentNode = this.nodes;
            let found = null;
            let flag = false;

            const segments = pathname.split('/');
            segments.forEach((segment, idx) => {
                found = _.find(parentNode, { title: segment });
                console.log(`findParentDir() found: ${JSON.stringify(found, null, 4)}`);
                if (found && idx < segments.length - 1) {
                    parentNode = found.children;
                } else if (found) {
                    flag = true;
                } else {
                    console.error('findParentDir() NOT FOUND!!');
                }
            });

return flag ? parentNode : null;
        },

        removeNode(node) {
            // console.log(`removeNode() node: ${JSON.stringify(node, null, 4)}`);
            this.selectedNode = node;
            let parentNode;
            if (node.isLeaf) parentNode = this.findParentNode(node.data.pathname);
            else parentNode = this.findParentDir(node.data.pathname, true);
            const foundIdx = _.findIndex(parentNode, { title: node.title });
            parentNode.splice(foundIdx, 1);
        },
    }
}

</script>

<style>

.vue-file-tree-contextmenu {
    position: absolute;
    background-color: white;
    color: black;
    border-radius: 2px;
    cursor: pointer;
}

.vue-file-tree-contextmenu > div {
    padding: 10px;
}

.vue-file-tree-contextmenu > div:hover {
    background-color: rgba(100, 100, 255, 0.5);
}

#vue-file-tree {
    height: 100%;
}

.sl-vue-tree {
    position: relative;
    cursor: default;
    user-select: none;
}

.sl-vue-tree.sl-vue-tree-root {
    border: 1px solid rgb(9, 22, 29);
    background-color: rgb(9, 22, 29);
    color: rgba(255, 255, 255, 0.5);
    border-radius: 3px;
}

.sl-vue-tree-root > .sl-vue-tree-nodes-list {
    overflow: hidden;
    position: relative;
    padding-bottom: 4px;
}

.sl-vue-tree-selected > .sl-vue-tree-node-item {
    background-color: #13242d;
    color: white;
}

.sl-vue-tree-node-item:hover,
.sl-vue-tree-node-item.sl-vue-tree-cursor-hover {
    color: white;
}

.sl-vue-tree-node-item {
    position: relative;
    display: flex;
    flex-direction: row;

    padding-left: 10px;
    padding-right: 10px;
    line-height: 28px;
    border: 1px solid transparent;
}


.sl-vue-tree-node-item.sl-vue-tree-cursor-inside {
    border: 1px solid rgba(255, 255, 255, 0.5);
}

.sl-vue-tree-gap {
    width: 25px;
    min-height: 1px;

}

.sl-vue-tree-toggle {
    display: inline-block;
    text-align: left;
    width: 20px;
}

.sl-vue-tree-sidebar {
    margin-left: auto;
}

.sl-vue-tree-cursor {
    position: absolute;
    border: 1px solid rgba(255, 255, 255, 0.5);
    height: 1px;
    width: 100%;
}

.sl-vue-tree-drag-info {
    position: absolute;
    background-color: rgba(0,0,0,0.5);
    opacity: 0.5;
    margin-left: 20px;
    padding: 5px 10px;
}

</style>