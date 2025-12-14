// 전역 변수
let todos = [];
let currentFilter = 'all';

// DOM 요소
const todoForm = document.getElementById('todo-form');
const todoInput = document.getElementById('todo-input');
const todoList = document.getElementById('todo-list');
const emptyState = document.getElementById('empty-state');
const clearCompletedBtn = document.getElementById('clear-completed');
const filterBtns = document.querySelectorAll('.filter-btn');
const totalCount = document.getElementById('total-count');
const activeCount = document.getElementById('active-count');
const completedCount = document.getElementById('completed-count');

// 로컬 스토리지 키
const STORAGE_KEY = 'todos';

// 초기화
document.addEventListener('DOMContentLoaded', () => {
    loadTodos();
    renderTodos();
    updateStats();
    updateClearButton();
});

// 이벤트 리스너
todoForm.addEventListener('submit', (e) => {
    e.preventDefault();
    addTodo();
});

clearCompletedBtn.addEventListener('click', clearCompleted);

filterBtns.forEach(btn => {
    btn.addEventListener('click', (e) => {
        setFilter(e.target.dataset.filter);
    });
});

// 할 일 추가
function addTodo() {
    const text = todoInput.value.trim();
    
    if (text === '') {
        alert('할 일을 입력해주세요!');
        return;
    }

    const todo = {
        id: Date.now(),
        text: text,
        completed: false,
        createdAt: new Date().toISOString()
    };

    todos.push(todo);
    saveTodos();
    renderTodos();
    updateStats();
    updateClearButton();
    
    todoInput.value = '';
    todoInput.focus();
}

// 할 일 토글
function toggleTodo(id) {
    const todo = todos.find(t => t.id === id);
    if (todo) {
        todo.completed = !todo.completed;
        saveTodos();
        renderTodos();
        updateStats();
        updateClearButton();
    }
}

// 할 일 삭제
function deleteTodo(id) {
    if (confirm('이 항목을 삭제하시겠습니까?')) {
        todos = todos.filter(t => t.id !== id);
        saveTodos();
        renderTodos();
        updateStats();
        updateClearButton();
    }
}

// 할 일 수정
function editTodo(id) {
    const todoItem = document.querySelector(`[data-id="${id}"]`);
    const todoContent = todoItem.querySelector('.todo-content');
    const currentText = todoContent.textContent;
    
    todoItem.classList.add('editing');
    
    const editInput = document.createElement('input');
    editInput.type = 'text';
    editInput.className = 'edit-input';
    editInput.value = currentText;
    
    const editActions = document.createElement('div');
    editActions.className = 'edit-actions';
    
    const saveBtn = document.createElement('button');
    saveBtn.className = 'btn-save';
    saveBtn.textContent = '저장';
    saveBtn.onclick = () => saveTodoEdit(id, editInput.value);
    
    const cancelBtn = document.createElement('button');
    cancelBtn.className = 'btn-cancel';
    cancelBtn.textContent = '취소';
    cancelBtn.onclick = () => cancelTodoEdit(id);
    
    editActions.appendChild(saveBtn);
    editActions.appendChild(cancelBtn);
    
    todoItem.insertBefore(editInput, todoContent);
    todoItem.appendChild(editActions);
    
    editInput.focus();
    editInput.select();
    
    // Enter 키로 저장
    editInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            saveTodoEdit(id, editInput.value);
        }
    });
    
    // ESC 키로 취소
    editInput.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            cancelTodoEdit(id);
        }
    });
}

// 할 일 수정 저장
function saveTodoEdit(id, newText) {
    const text = newText.trim();
    
    if (text === '') {
        alert('할 일을 입력해주세요!');
        return;
    }
    
    const todo = todos.find(t => t.id === id);
    if (todo) {
        todo.text = text;
        saveTodos();
        renderTodos();
    }
}

// 할 일 수정 취소
function cancelTodoEdit(id) {
    renderTodos();
}

// 완료된 할 일 모두 삭제
function clearCompleted() {
    const completedTodos = todos.filter(t => t.completed);
    
    if (completedTodos.length === 0) {
        return;
    }
    
    if (confirm(`완료된 ${completedTodos.length}개 항목을 모두 삭제하시겠습니까?`)) {
        todos = todos.filter(t => !t.completed);
        saveTodos();
        renderTodos();
        updateStats();
        updateClearButton();
    }
}

// 필터 설정
function setFilter(filter) {
    currentFilter = filter;
    
    filterBtns.forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.filter === filter) {
            btn.classList.add('active');
        }
    });
    
    renderTodos();
}

// 필터링된 할 일 가져오기
function getFilteredTodos() {
    switch (currentFilter) {
        case 'active':
            return todos.filter(t => !t.completed);
        case 'completed':
            return todos.filter(t => t.completed);
        default:
            return todos;
    }
}

// 할 일 렌더링
function renderTodos() {
    const filteredTodos = getFilteredTodos();
    
    todoList.innerHTML = '';
    
    if (filteredTodos.length === 0) {
        emptyState.classList.add('show');
        todoList.style.display = 'none';
    } else {
        emptyState.classList.remove('show');
        todoList.style.display = 'block';
        
        filteredTodos.forEach(todo => {
            const li = createTodoElement(todo);
            todoList.appendChild(li);
        });
    }
}

// 할 일 요소 생성
function createTodoElement(todo) {
    const li = document.createElement('li');
    li.className = `todo-item ${todo.completed ? 'completed' : ''}`;
    li.dataset.id = todo.id;
    
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.className = 'todo-checkbox';
    checkbox.checked = todo.completed;
    checkbox.addEventListener('change', () => toggleTodo(todo.id));
    
    const content = document.createElement('span');
    content.className = 'todo-content';
    content.textContent = todo.text;
    
    const actions = document.createElement('div');
    actions.className = 'todo-actions';
    
    const editBtn = document.createElement('button');
    editBtn.className = 'btn-edit';
    editBtn.textContent = '수정';
    editBtn.addEventListener('click', () => editTodo(todo.id));
    
    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'btn-delete';
    deleteBtn.textContent = '삭제';
    deleteBtn.addEventListener('click', () => deleteTodo(todo.id));
    
    actions.appendChild(editBtn);
    actions.appendChild(deleteBtn);
    
    li.appendChild(checkbox);
    li.appendChild(content);
    li.appendChild(actions);
    
    return li;
}

// 통계 업데이트
function updateStats() {
    const total = todos.length;
    const active = todos.filter(t => !t.completed).length;
    const completed = todos.filter(t => t.completed).length;
    
    totalCount.textContent = total;
    activeCount.textContent = active;
    completedCount.textContent = completed;
}

// 완료 삭제 버튼 상태 업데이트
function updateClearButton() {
    const hasCompleted = todos.some(t => t.completed);
    clearCompletedBtn.disabled = !hasCompleted;
}

// 로컬 스토리지에 저장
function saveTodos() {
    try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
    } catch (error) {
        console.error('로컬 스토리지 저장 실패:', error);
        alert('데이터 저장에 실패했습니다. 브라우저의 로컬 스토리지를 확인해주세요.');
    }
}

// 로컬 스토리지에서 불러오기
function loadTodos() {
    try {
        const stored = localStorage.getItem(STORAGE_KEY);
        if (stored) {
            todos = JSON.parse(stored);
        }
    } catch (error) {
        console.error('로컬 스토리지 로드 실패:', error);
        alert('데이터 로드에 실패했습니다. 새로 시작합니다.');
        todos = [];
    }
}
