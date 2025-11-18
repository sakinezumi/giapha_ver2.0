<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Phả đồ — GiaPhả</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <header class="navbar small">
    <a class="brand" href="index.jsp">GiaPhả<span class="brand-dot">.</span></a>
    <nav class="breadcrumb">
      <a href="index.jsp">Trang chủ</a> / <span>Phả đồ</span>
    </nav>
    <div class="nav-actions">
      <a class="btn ghost" href="index.jsp">Quay về</a>
    </div>
  </header>

  <main class="container">
    <section class="panel">
      <div class="panel-head">
        <h2>Phả đồ</h2>
        <div class="actions">
          <button class="btn ghost" id="btnToggleAddRoot">Thêm đời đầu</button>
          <button class="btn" id="btnShare">Chia sẻ</button>
        </div>
      </div>

      <div class="layout-row">
        <aside class="side">
          <div class="card small">
            <input id="searchInput" placeholder="Tìm tên / năm..." class="search-input">
            <button class="btn" id="btnSearch" style="width:100%;margin-top:8px">Tìm kiếm</button>
          </div>
          
          <div id="addRootForm" class="card small hidden" style="margin-top:12px">
            <h4>Thêm đời đầu</h4>
            <div class="form-row"><label>Tên</label><input id="addRootName"></div>
            <div class="form-row"><label>Năm sinh</label><input id="addRootYear" type="number"></div>
            <button class="btn" id="btnAddRoot" style="width:100%">Thêm</button>
          </div>

          <div id="memberDetails" class="card small hidden" style="margin-top:12px">
            <h4>Chi tiết thành viên</h4>
            <div class="muted-small" id="memberId"></div>
            <div class="details-card">
              <div class="form-row"><label>Tên</label><input id="detailName" readonly></div>
              <div class="form-row"><label>Năm sinh</label><input id="detailYear" type="number" readonly></div>
              <div class="form-row"><label>Giới tính</label>
                <select id="detailGender" disabled>
                  <option value="male">Nam</option><option value="female">Nữ</option><option value="other">Khác</option>
                </select>
              </div>
              <div class="form-row"><label>Quan hệ</label><input id="detailRelation" readonly></div>
              <div class="form-row"><label>Parent ID</label><div id="detailParent" class="muted-small">—</div></div>
              <div class="form-row"><label>Spouse ID</label><div id="detailSpouse" class="muted-small">—</div></div>
            </div>

            <div style="margin-top:12px;display:flex;gap:8px">
              <button class="btn ghost" id="btnEdit">Chỉnh sửa</button>
              <button class="btn hidden" id="btnSave">Lưu</button>
              <button class="btn hidden" id="btnCancelEdit">Hủy</button>
            </div>
            <div style="margin-top:12px;display:flex;gap:8px;border-top:1px solid rgba(2,6,23,0.04);padding-top:12px">
              <button class="btn" id="btnAddChild">Thêm con</button>
              <button class="btn ghost" id="btnAddSpouse">Thêm vợ/chồng</button>
              <button class="btn danger" id="btnDelete">Xóa</button>
            </div>
          </div>
        </aside>

        <div class="main-area">
          <div class="tree-toolbar">
            <label><input type="checkbox" id="toggleRelationship"> Đường hôn phối</label>
            <label><input type="checkbox" id="toggleId"> Hiển thị ID</label>
            <div style="flex-grow:1;text-align:right">
              <button class="btn ghost" id="btnZoomIn">Zoom in</button>
              <button class="btn ghost" id="btnZoomOut">Zoom out</button>
              <button class="btn ghost" id="btnFit">Fit</button>
            </div>
          </div>
          <div id="familyTree" class="family-tree">
            <div class="muted" style="padding:40px;text-align:center">Đang tải dữ liệu...</div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <footer class="footer small">
    <div>© 2025 — GiaPhả</div>
  </footer>

  <div id="modalShare" class="modal hidden">
    <div class="modal-card">
      <h4>Chia sẻ dữ liệu</h4>
      <p class="muted-small">Dữ liệu gia phả hiện tại (JSON) có thể được sao chép để chia sẻ.</p>
      <textarea id="shareJson" readonly style="width:100%;height:150px;margin-bottom:12px;padding:10px;border-radius:8px"></textarea>
      <div style="display:flex;justify-content:flex-end;gap:8px">
        <button class="btn ghost" id="btnCloseShare">Đóng</button>
        <button class="btn" id="btnCopyShare">Sao chép JSON</button>
      </div>
    </div>
  </div>

  <div id="modalNew" class="modal hidden">
    <div class="modal-card">
      <h4 id="modalNewTitle">Thêm thành viên</h4>
      <p class="muted-small" id="modalNewContext"></p>
      <div class="form-row"><label>Tên</label><input id="newMemName"></div>
      <div class="form-row"><label>Năm sinh</label><input id="newMemYear" type="number"></div>
      <div class="form-row"><label>Giới tính</label>
        <select id="newMemGender"><option value="male">Nam</option><option value="female">Nữ</option><option value="other">Khác</option></select>
      </div>
      <div style="display:flex;justify-content:flex-end;gap:8px">
        <button class="btn ghost" id="btnCloseNew">Hủy</button>
        <button class="btn" id="btnConfirmNew">Xác nhận</button>
      </div>
    </div>
  </div>
  
  <script>
    function uid() { return 'id-' + Math.random().toString(36).substring(2, 10); }

    async function loadFamily(){
        try {
            const response = await fetch('loadData.jsp?key=gp_family');
            if (!response.ok) throw new Error('Network response was not ok');
            const data = await response.json();
            return data.value || { members: [] };
        } catch (error) {
            console.error('Lỗi tải dữ liệu gia phả:', error);
            return { members: [] };
        }
    }

    async function saveFamily(familyData){
        const formData = new URLSearchParams();
        formData.append('key', 'gp_family');
        formData.append('value', JSON.stringify(familyData));

        try {
            const response = await fetch('saveData.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            });
            if (!response.ok) throw new Error('Network response was not ok');
            const result = await response.json();
            if(result.status === 'success'){
                console.log('Lưu dữ liệu thành công!');
            } else {
                throw new Error(result.error || 'Lỗi lưu dữ liệu');
            }
        } catch (error) {
            console.error('Lỗi lưu dữ liệu gia phả:', error);
            alert('Lỗi: Không lưu được dữ liệu gia phả vào Database.');
        }
    }
    
    async function loadActivity(){
      try {
          const response = await fetch('loadData.jsp?key=gp_activity');
          if (!response.ok) return [];
          return await response.json();
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
      logs.unshift({ time: new Date().toLocaleString(), text });
      if(logs.length>500) logs.pop();
      await saveActivity(logs);
    }

    let family = { members: [] };
    let selectedId = null; 

    const findMember = (id) => family.members.find(m => m.id === id);

    async function renderTree() {
      family = await loadFamily();
      const el = document.getElementById('familyTree');
      el.innerHTML = '';
      
      const rootMembers = family.members.filter(m => !m.parentId);
      if (rootMembers.length === 0) {
          el.innerHTML = '<div class="muted" style="padding:40px;text-align:center">Chưa có thành viên nào. Thêm đời đầu để bắt đầu.</div>';
          return;
      }
      
      const buildNode = (member) => {
        const node = document.createElement('div');
        node.className = 'node' + (member.id === selectedId ? ' active' : '');
        node.dataset.id = member.id;
        node.onclick = () => selectMember(member.id);
        
        node.innerHTML = `
          <strong>${member.name}</strong>
          <div class="muted-small">${member.year || '—'}</div>
          ${findMember(member.spouseId) ? `<div class="spouse">+ ${findMember(member.spouseId).name}</div>` : ''}
          <div class="id-tag hidden">${member.id}</div>
        `;
        return node;
      };
      
      const renderBranch = (parentId, container) => {
          const children = family.members.filter(m => m.parentId === parentId);
          if (children.length === 0) return;

          const childrenContainer = document.createElement('div');
          childrenContainer.className = 'children';

          children.forEach(child => {
              const childNodeContainer = document.createElement('div');
              childNodeContainer.className = 'node-container';
              childNodeContainer.appendChild(buildNode(child));
              renderBranch(child.id, childNodeContainer);
              childrenContainer.appendChild(childNodeContainer);
          });
          container.appendChild(childrenContainer);
      };

      const treeContainer = document.createElement('div');
      treeContainer.className = 'tree-root';
      
      rootMembers.forEach(root => {
        const rootContainer = document.createElement('div');
        rootContainer.className = 'node-container';
        rootContainer.appendChild(buildNode(root));
        renderBranch(root.id, rootContainer);
        treeContainer.appendChild(rootContainer);
      });
      
      el.appendChild(treeContainer);
      
      document.getElementById('toggleRelationship').checked = localStorage.getItem('gp_show_rel') === 'true';
      document.getElementById('toggleId').checked = localStorage.getItem('gp_show_id') === 'true';
      toggleDisplay(document.getElementById('toggleRelationship').checked, 'show-rel');
      toggleDisplay(document.getElementById('toggleId').checked, 'show-id');
    }

    async function selectMember(id) {
        selectedId = id;
        document.querySelectorAll('.node').forEach(n => n.classList.remove('active'));
        document.querySelector(`.node[data-id="${id}"]`)?.classList.add('active');
        
        const member = findMember(id);
        if (member) {
            document.getElementById('memberDetails').classList.remove('hidden');
            document.getElementById('memberId').textContent = 'ID: ' + member.id;
            document.getElementById('detailName').value = member.name;
            document.getElementById('detailYear').value = member.year || '';
            document.getElementById('detailGender').value = member.gender || 'male';
            document.getElementById('detailRelation').value = member.relation || '';
            document.getElementById('detailParent').textContent = member.parentId || '—';
            document.getElementById('detailSpouse').textContent = member.spouseId || '—';
        }
        document.getElementById('addRootForm').classList.add('hidden');
    }

    function toggleDisplay(checked, className) {
        document.getElementById('familyTree').classList.toggle(className, checked);
        localStorage.setItem(className.replace('-', '_'), checked);
    }
    
    document.getElementById('toggleRelationship').addEventListener('change', (e) => toggleDisplay(e.target.checked, 'show-rel'));
    document.getElementById('toggleId').addEventListener('change', (e) => toggleDisplay(e.target.checked, 'show-id'));

    document.getElementById('btnToggleAddRoot').addEventListener('click', () => {
        document.getElementById('addRootForm').classList.toggle('hidden');
        selectedId = null;
        document.getElementById('memberDetails').classList.add('hidden');
        document.querySelectorAll('.node').forEach(n => n.classList.remove('active'));
    });
    
    document.getElementById('btnAddRoot').addEventListener('click', async () => {
      const name = document.getElementById('addRootName').value.trim();
      const year = document.getElementById('addRootYear').value.trim();
      if (!name) return alert('Nhập tên');
      
      const newMem = {
          id: uid(),
          name,
          year: year ? parseInt(year) : null,
          gender: 'male',
      };
      family.members.push(newMem);
      
      await saveFamily(family);
      await pushActivity('Thêm đời đầu: ' + name);
      document.getElementById('addRootForm').classList.add('hidden');
      renderTree();
    });
    
    document.getElementById('btnEdit').addEventListener('click', () => {
        document.getElementById('detailName').removeAttribute('readonly');
        document.getElementById('detailYear').removeAttribute('readonly');
        document.getElementById('detailGender').removeAttribute('disabled');
        document.getElementById('detailRelation').removeAttribute('readonly');
        document.getElementById('btnEdit').classList.add('hidden');
        document.getElementById('btnSave').classList.remove('hidden');
        document.getElementById('btnCancelEdit').classList.remove('hidden');
    });

    document.getElementById('btnCancelEdit').addEventListener('click', () => {
        selectMember(selectedId);
        document.getElementById('detailName').setAttribute('readonly', true);
        document.getElementById('detailYear').setAttribute('readonly', true);
        document.getElementById('detailGender').setAttribute('disabled', true);
        document.getElementById('detailRelation').setAttribute('readonly', true);
        document.getElementById('btnEdit').classList.remove('hidden');
        document.getElementById('btnSave').classList.add('hidden');
        document.getElementById('btnCancelEdit').classList.add('hidden');
    });

    document.getElementById('btnSave').addEventListener('click', async () => {
        const member = findMember(selectedId);
        if (!member) return;

        member.name = document.getElementById('detailName').value.trim();
        member.year = document.getElementById('detailYear').value.trim() ? parseInt(document.getElementById('detailYear').value.trim()) : null;
        member.gender = document.getElementById('detailGender').value;
        member.relation = document.getElementById('detailRelation').value.trim();

        await saveFamily(family);
        await pushActivity('Cập nhật thành viên: ' + member.name);
        
        document.getElementById('btnCancelEdit').click();
        renderTree();
    });
    
    document.getElementById('btnDelete').addEventListener('click', async () => {
        if (!selectedId) return;
        const member = findMember(selectedId);
        if (!confirm('Xác nhận xóa thành viên: ' + member.name + '? (Sẽ xóa cả con và vợ/chồng)')) return;
        
        family.members = family.members.filter(m => m.id !== selectedId && m.parentId !== selectedId && m.spouseId !== selectedId);
        
        await saveFamily(family);
        await pushActivity('Xóa thành viên: ' + member.name);
        
        selectedId = null;
        document.getElementById('memberDetails').classList.add('hidden');
        renderTree();
    });
    
    let modalType = '';
    document.getElementById('btnAddChild').addEventListener('click', () => {
        if(!selectedId) return alert('Chọn thành viên để thêm con.');
        modalType = 'child';
        document.getElementById('modalNewTitle').textContent = 'Thêm con';
        document.getElementById('modalNewContext').textContent = `Con của ${findMember(selectedId).name}`;
        document.getElementById('modalNew').classList.remove('hidden');
    });
    
    document.getElementById('btnAddSpouse').addEventListener('click', () => {
        if(!selectedId) return alert('Chọn thành viên để thêm vợ/chồng.');
        const member = findMember(selectedId);
        if(member.spouseId) return alert(member.name + ' đã có vợ/chồng.');
        modalType = 'spouse';
        document.getElementById('modalNewTitle').textContent = 'Thêm vợ/chồng';
        document.getElementById('modalNewContext').textContent = `Vợ/chồng của ${member.name}`;
        document.getElementById('modalNew').classList.remove('hidden');
    });
    
    document.getElementById('btnCloseNew').addEventListener('click', () => document.getElementById('modalNew').classList.add('hidden'));

    document.getElementById('btnConfirmNew').addEventListener('click', async () => {
        const name = document.getElementById('newMemName').value.trim();
        const year = document.getElementById('newMemYear').value.trim();
        const gender = document.getElementById('newMemGender').value;

        if (!name) return alert('Nhập tên');
        
        const newMem = {
            id: uid(),
            name,
            year: year ? parseInt(year) : null,
            gender: gender,
        };

        const currentMem = findMember(selectedId);
        
        if (modalType === 'child') {
            newMem.parentId = selectedId;
            family.members.push(newMem);
            await pushActivity('Thêm con: ' + name + ' cho ' + currentMem.name);
        } else if (modalType === 'spouse') {
            newMem.spouseId = selectedId;
            currentMem.spouseId = newMem.id;
            family.members.push(newMem);
            await pushActivity('Thêm vợ/chồng: ' + name + ' cho ' + currentMem.name);
        }
        
        await saveFamily(family);
        document.getElementById('modalNew').classList.add('hidden');
        document.getElementById('newMemName').value = '';
        document.getElementById('newMemYear').value = '';
        renderTree();
    });

    document.getElementById('btnSearch').addEventListener('click', () => {
        const query = document.getElementById('searchInput').value.trim().toLowerCase();
        if(!query) return;
        const found = family.members.find(m => m.name.toLowerCase().includes(query) || (m.year && m.year.toString().includes(query)));
        if(found) {
            selectMember(found.id);
            alert(`Tìm thấy: ${found.name} (ID: ${found.id})`);
        } else {
            alert('Không tìm thấy thành viên phù hợp.');
        }
    });

    document.getElementById('btnShare').addEventListener('click', async () => {
        const data = await loadFamily();
        document.getElementById('shareJson').value = JSON.stringify(data, null, 2);
        document.getElementById('modalShare').classList.remove('hidden');
    });
    document.getElementById('btnCloseShare').addEventListener('click', ()=> document.getElementById('modalShare').classList.add('hidden'));
    document.getElementById('btnCopyShare').addEventListener('click', async ()=> {
      const t = document.getElementById('shareJson');
      t.select();
      document.execCommand('copy');
      alert('JSON đã được sao chép vào clipboard.');
      await pushActivity('Chia sẻ phả đồ (sao chép JSON)');
    });

    document.getElementById('btnZoomIn').addEventListener('click', ()=> alert('Zoom in (demo)'));
    document.getElementById('btnZoomOut').addEventListener('click', ()=> alert('Zoom out (demo)'));
    document.getElementById('btnFit').addEventListener('click', ()=> alert('Fit to screen (demo)'));

    (async function() {
        await renderTree();
    })();
  </script>
  
  <style>
    .node .spouse{margin-top:6px;color:#c026d3;font-weight:600}
    .modal{position:fixed;inset:0;display:flex;align-items:center;justify-content:center;background:rgba(2,6,23,0.45);z-index:60}
    .modal.hidden{display:none}
    .modal-card{background:white;padding:18px;border-radius:12px;max-width:720px;width:90%;box-shadow:var(--shadow)}
    .node-container{position:relative;display:flex;flex-direction:column;align-items:center}
    .node{background:linear-gradient(180deg,#f8f8ff,#fefeff);padding:12px 16px;border-radius:10px;box-shadow:0 8px 16px rgba(0,0,0,0.05);margin:10px;cursor:pointer;transition:transform 0.2s,box-shadow 0.2s}
    .node:hover{transform:translateY(-6px);box-shadow:0 12px 24px rgba(0,0,0,0.1)}
    .node strong{font-weight:700;font-size:16px}
    .node .muted-small{font-size:13px;margin-top:6px}
    .node.active{outline:3px solid rgba(124,58,237,0.12);box-shadow:0 20px 60px rgba(124,58,237,0.05)}
    .family-tree.show-id .id-tag{display:block}
    .id-tag{font-size:10px;color:#06b6d4;margin-top:4px;display:none}
    .tree-root{display:flex;justify-content:center;padding:20px 0}
    .children{display:flex;justify-content:center;position:relative;padding-top:20px}
    .children::before{content:'';position:absolute;top:0;left:0;right:0;height:1px;background:#ddd}
    .node-container{position:relative}
    .node-container::before{content:'';position:absolute;top:-10px;left:50%;width:1px;height:10px;background:#ddd}
  </style>
</body>
</html>