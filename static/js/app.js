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
                // 检查是否包含log_format指令或主配置文件的元素
                const hasLogFormat = this.currentValue.includes('log_format');
                const isMainConfig = this.currentValue.includes('worker_processes') || 
                                    this.currentValue.includes('error_log') || 
                                    this.currentValue.includes('pid') ||
                                    this.currentValue.includes('events {');
                
                // 检查大括号是否匹配
                const openBraces = (this.currentValue.match(/{/g) || []).length;
                const closeBraces = (this.currentValue.match(/}/g) || []).length;
                
                if (openBraces !== closeBraces) {
                    throw new Error(`括号不匹配: 发现 ${openBraces} 个开括号和 ${closeBraces} 个闭括号`);
                }
                
                // 检查是否完全没有括号，这可能是配置错误
                if (openBraces === 0 && closeBraces === 0) {
                    if (!this.currentValue.includes(';')) {
                        throw new Error('无效的Nginx配置: 缺少分号和块结构');
                    }
                }

                // 对于log_format或主配置，进行简化的验证
                if (hasLogFormat || isMainConfig) {
                    // 对于主配置，检查events块
                    if (isMainConfig && !this.currentValue.includes('events')) {
                        throw new Error('Nginx主配置缺少必要的events块');
                    } else {
                        this.validationResult = {
                            valid: true,
                            message: 'NGINX configuration is valid'
                        };
                        return true;
                    }
                }
                
                // 对于其他配置，检查server块
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
                // 检查路径是否包含hosts关键字，表示这是hosts文件
                if (this.selectedKey.includes('/hosts/')) {
                    // 对于hosts文件，检查是否包含至少一个有效行（IP + 主机名）
                    const lines = this.currentValue.split('\n');
                    for (const line of lines) {
                        const trimmedLine = line.trim();
                        // 跳过空行和注释行
                        if (trimmedLine === '' || trimmedLine.startsWith('#')) {
                            continue;
                        }
                        // 检查是否至少有两个字段，第一个是IP地址格式
                        const fields = trimmedLine.split(/\s+/);
                        if (fields.length >= 2) {
                            const ipParts = fields[0].split('.');
                            if (ipParts.length === 4) {
                                // 找到至少一个看起来像 IP 的行，认为格式有效
                                this.validationResult = {
                                    valid: true,
                                    message: 'CoreDNS hosts文件配置有效'
                                };
                                return true;
                            }
                        }
                    }
                    
                    // 没有找到有效的IP映射行
                    throw new Error('无效的hosts配置: 缺少IP地址到主机名的映射');
                }
                
                // 原有CoreDNS配置验证逻辑
                if (!this.currentValue.includes('.') && 
                    !this.currentValue.includes(':') && 
                    !this.currentValue.includes('/')) {
                    throw new Error('Invalid CoreDNS configuration: missing domain, IP, or path format');
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