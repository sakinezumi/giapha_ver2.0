<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Quản trị — GiaPhả</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <header class="navbar small">
    <a class="brand" href="index.jsp">GiaPhả<span class="brand-dot">.</span></a>
    <nav class="breadcrumb">
      <a href="index.jsp">Trang chủ</a> / <span>Quản trị</span>
    </nav>
    <div class="nav-actions">
      <a class="btn ghost" href="index.jsp">Quay về</a>
    </div>
  </header>

  <main class="container">
    <section class="panel">
      <div class="panel-head">
        <h2>Quản trị hệ thống</h2>
        <div class="actions">
          <button class="btn" id="btnAddAdmin">Thêm quản trị</button>
        </div>
      </div>

      <div class="grid-2">
        <div class="card">
          <h4>Activity log (Nhật ký hoạt động)</h4>
          <div id="activityList" style="max-height:320px;overflow:auto;padding-top:8px"></div>
          <div style="margin-top:10px;text-align:right">
            <button class="btn ghost" id="btnClearActivity">Xóa nhật ký</button>
          </div>
        </div>

        <div class="card">
          <h4>Quản lý người dùng & phân quyền</h4>
          <div id="userList">
            <div class="muted" style="padding:10px">Đang tải người dùng...</div>
          </div>

          <div style="margin-top:12px">
            <form id="frmUser">
              <div class="form-row"><label>Tên</label><input id="u_name" required></div>
              <div class="form-row"><label>Vai trò</label>
                <select id="u_role"><option value="user">Người dùng</option><option value="admin">Quản trị</option></select>
              </div>
              <div style="display:flex;gap:8px">
                <button class="btn" type="submit" id="btnCreateUser">Tạo</button>
                <button class="btn ghost" id="btnResetUser" type="reset">Đặt lại</button>
              </div>
            </form>
          </div>
        </div>
      </div>

    </section>
  </main>

  <footer class="footer small">
    <div>© 2025 — GiaPhả</div>
  </footer>

  <script>
    function uid() { return 'u-' + Math.random().toString(36).substring(2, 10); }
    function nowStr(){ return new Date().toLocaleString(); }

    async function loadUsers(){
        try {
            const response = await fetch('loadData.jsp?key=gp_users');
            if (!response.ok) return [];
            const data = await response.json();
            return Array.isArray(data) ? data : [];
        } catch (error) { return []; }
    }
    
    async function saveUsers(users){
        const formData = new URLSearchParams();
        formData.append('key', 'gp_users');
        formData.append('value', JSON.stringify(users));
        try {
            await fetch('saveData.jsp', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: formData });
        } catch (error) { console.error('Lỗi lưu User:', error); }
    }
    
    async function loadActivity(){
      try {
          const response = await fetch('loadData.jsp?key=gp_activity');
          if (!response.ok) return [];
          const data = await response.json();
          return Array.isArray(data) ? data : [];
      } catch (error) { return []; }
    }
    
    async function saveActivity(logs){
        const formData = new URLSearchParams();
        formData.append('key', 'gp_activity');
        formData.append('value', JSON.stringify(logs));
        try {
            await fetch('saveData.jsp', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: formData });
        } catch (error) { console.error('Lỗi lưu Activity Log:', error); }
    }

    async function pushActivity(text){
      const logs = await loadActivity();
      logs.unshift({ time: nowStr(), text });
      if(logs.length>500) logs.pop();
      await saveActivity(logs);
      renderActivity();
    }

    async function renderUsers(){
      const users = await loadUsers();
      const el = document.getElementById('userList');
      if(users.length === 0){
        el.innerHTML = '<div class="muted" style="padding:10px">Chưa có người dùng nào.</div>';
        return;
      }
      
      el.innerHTML = users.map(u => `
        <div style="display:flex;justify-content:space-between;align-items:center;padding:6px;border-bottom:1px solid rgba(2,6,23,0.04)">
          <div><strong>${u.name}</strong><div class="muted-small">${u.role}</div></div>
          <div>
            <button class="btn ghost" onclick="toggleRole('${u.id}', '${u.name}')">Đổi vai trò</button>
            <button class="btn danger" onclick="deleteUser('${u.id}', '${u.name}')">Xóa</button>
          </div>
        </div>
      `).join('');
    }

    async function toggleRole(id, name){
      if(!confirm(`Đổi vai trò cho user ${name}?`)) return;
      let users = await loadUsers();
      const user = users.find(x => x.id === id);
      if(user){
        user.role = user.role === 'admin' ? 'user' : 'admin';
        await saveUsers(users);
        await pushActivity(`Đổi vai trò user ${name} thành ${user.role}`);
        renderUsers();
      }
    }

    async function deleteUser(id, name){
      if(!confirm(`Xóa user: ${name}?`)) return;
      let users = await loadUsers();
      users = users.filter(x=>x.id!==id);
      await saveUsers(users);
      await pushActivity('Xóa user (id=' + id + ')');
      renderUsers();
    }

    document.getElementById('frmUser').addEventListener('submit', async (e)=>{
      e.preventDefault();
      const name = document.getElementById('u_name').value.trim();
      const role = document.getElementById('u_role').value;
      if(!name) return alert('Nhập tên');
      
      const u = { id: uid(), name, role };
      let users = await loadUsers();
      users.push(u);
      
      await saveUsers(users);
      await pushActivity('Tạo user: ' + name + ' (' + role + ')');
      renderUsers();
      document.getElementById('u_name').value = '';
    });
    
    async function renderActivity(){
      const logs = await loadActivity();
      const el = document.getElementById('activityList');
      el.innerHTML = logs.map(l=>`<div class="muted-small" style="padding:6px;border-bottom:1px solid rgba(2,6,23,0.04)"><strong>${l.time}</strong><div style="margin-top:4px">${l.text}</div></div>`).join('') || '<div class="muted">Chưa có hoạt động</div>';
    }

    document.getElementById('btnClearActivity').addEventListener('click', async ()=>{
      if(!confirm('Xóa toàn bộ nhật ký hoạt động?')) return;
      await saveActivity([]);
      await pushActivity('Xóa nhật ký hoạt động (by admin)');
      renderActivity();
    });

    document.getElementById('btnAddAdmin').addEventListener('click', ()=> {
      document.getElementById('u_name').value = 'quản trị mới';
      document.getElementById('u_role').value = 'admin';
    });
    
    document.getElementById('btnResetUser').addEventListener('click', ()=> {
      document.getElementById('u_name').value = '';
      document.getElementById('u_role').value = 'user';
    });

    (async function() {
        await renderActivity();
        await renderUsers();
    })();
  </script>
</body>
</html>