const app = Vue.createApp({
    data() {
        return {
            isLoggedIn: false,
            username: '',
            password: '',
            search: '',
            selectedKey: '',
            currentValue: '',
            validationResult: null,
            treeData: []
        }
    },
    methods: {
        async login() {
            try {
                const response = await axios.post('/login', {
                    username: this.username,
                    password: this.password
                });
                if (response.data.status === 'ok') {
                    this.isLoggedIn = true;
                    this.loadTree();
                }
            } catch (error) {
                alert('Login failed: ' + error.response?.data?.message || error.message);
            }
        },
        logout() {
            this.isLoggedIn = false;
            this.username = '';
            this.password = '';
            this.selectedKey = '';
            this.currentValue = '';
        },
        async loadTree() {
            try {
                const response = await axios.get('/api/etcd/');
                this.treeData = this.buildTree(response.data.keys);
            } catch (error) {
                alert('Failed to load ETCD keys: ' + error.message);
            }
        },
        buildTree(keys) {
            const tree = [];
            keys.forEach(key => {
                const parts = key.split('/');
                let currentLevel = tree;
                parts.forEach((part, index) => {
                    if (!part) return;
                    let existing = currentLevel.find(node => node.label === part);
                    if (!existing) {
                        existing = {
                            label: part,
                            children: [],
                            path: parts.slice(0, index + 1).join('/')
                        };
                        currentLevel.push(existing);
                    }
                    currentLevel = existing.children;
                });
            });
            return tree;
        },
        async selectKey(key) {
            try {
                const response = await axios.get(`/api/etcd/${key}`);
                this.selectedKey = key;
                this.currentValue = response.data.value;
                this.validateValue();
            } catch (error) {
                alert('Failed to load key value: ' + error.message);
            }
        },
        async saveValue() {
            if (!this.selectedKey) return;
            try {
                if (!this.validateValue()) {
                    if (!confirm('The value does not pass validation. Do you want to save anyway?')) {
                        return;
                    }
                }
                await axios.put(`/api/etcd/${this.selectedKey}`, {
                    value: this.currentValue
                });
                alert('Value saved successfully');
            } catch (error) {
                alert('Failed to save value: ' + error.message);
            }
        },
        async deleteKey() {
            if (!this.selectedKey) return;
            if (!confirm(`Are you sure you want to delete ${this.selectedKey}?`)) {
                return;
            }
            try {
                await axios.delete(`/api/etcd/${this.selectedKey}`);
                this.selectedKey = '';
                this.currentValue = '';
                this.loadTree();
                alert('Key deleted successfully');
            } catch (error) {
                alert('Failed to delete key: ' + error.message);
            }
        },
        validateValue() {
            if (!this.currentValue) {
                this.validationResult = null;
                return true;
            }

            // 根据key路径判断验证类型
            if (this.selectedKey.startsWith('nginx/')) {
                return this.validateNginx();
            } else if (this.selectedKey.startsWith('coredns/')) {
                return this.validateCoreDNS();
            }

            this.validationResult = null;
            return true;
        },
        validateNginx() {
            try {
                // 这里可以添加更复杂的NGINX配置验证逻辑
                if (!this.currentValue.includes('server {')) {
                    throw new Error('Invalid NGINX configuration: missing server block');
                }
                this.validationResult = {
                    valid: true,
                    message: 'NGINX configuration is valid'
                };
                return true;
            } catch (error) {
                this.validationResult = {
                    valid: false,
                    message: error.message
                };
                return false;
            }
        },
        validateCoreDNS() {
            try {
                // 这里可以添加更复杂的CoreDNS配置验证逻辑
                if (!this.currentValue.includes('.')) {
                    throw new Error('Invalid CoreDNS configuration: missing domain');
                }
                this.validationResult = {
                    valid: true,
                    message: 'CoreDNS configuration is valid'
                };
                return true;
            } catch (error) {
                this.validationResult = {
                    valid: false,
                    message: error.message
                };
                return false;
            }
        }
    },
    mounted() {
        // 检查是否已登录
        axios.get('/api/auth/status')
            .then(response => {
                if (response.data.loggedIn) {
                    this.isLoggedIn = true;
                    this.loadTree();
                }
            })
            .catch(error => console.error('Failed to check auth status:', error));
    }
});

app.mount('#app'); 