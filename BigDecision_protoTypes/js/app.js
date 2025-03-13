// 获取当前时间并格式化为状态栏时间
function updateStatusBarTime() {
  const now = new Date();
  let hours = now.getHours();
  let minutes = now.getMinutes();
  
  // 格式化为两位数
  hours = hours < 10 ? '0' + hours : hours;
  minutes = minutes < 10 ? '0' + minutes : minutes;
  
  const timeString = `${hours}:${minutes}`;
  
  // 更新所有状态栏时间元素
  const timeElements = document.querySelectorAll('.status-bar-time');
  timeElements.forEach(el => {
    el.textContent = timeString;
  });
}

// 页面加载时更新时间，并每分钟更新一次
document.addEventListener('DOMContentLoaded', function() {
  updateStatusBarTime();
  setInterval(updateStatusBarTime, 60000);
  
  // 为所有标签项添加点击事件
  const tabItems = document.querySelectorAll('.tab-item');
  tabItems.forEach(item => {
    item.addEventListener('click', function() {
      // 移除所有活动状态
      tabItems.forEach(tab => tab.classList.remove('active'));
      // 添加当前项的活动状态
      this.classList.add('active');
    });
  });
  
  // 为选项卡添加点击事件
  const optionCards = document.querySelectorAll('.option-card');
  optionCards.forEach(card => {
    card.addEventListener('click', function() {
      this.classList.toggle('selected');
    });
  });
  
  // 为按钮添加点击效果
  const buttons = document.querySelectorAll('button');
  buttons.forEach(button => {
    button.addEventListener('click', function() {
      this.classList.add('opacity-75');
      setTimeout(() => {
        this.classList.remove('opacity-75');
      }, 150);
    });
  });
});

// 模拟API调用分析决定
function analyzeDecision(optionA, optionB, additionalInfo) {
  return new Promise((resolve) => {
    // 模拟API延迟
    setTimeout(() => {
      resolve({
        recommendation: optionB.title,
        analysis: {
          optionA: {
            pros: ["优点1", "优点2", "优点3"],
            cons: ["缺点1", "缺点2"]
          },
          optionB: {
            pros: ["优点1", "优点2", "优点3", "优点4"],
            cons: ["缺点1"]
          }
        },
        reasoning: "基于您提供的信息，选项B似乎更符合您的需求。选项B的优势更多，而且缺点较少。考虑到您提到的附加信息，选项B在长期来看可能会带来更多的收益和满足感。"
      });
    }, 2000);
  });
}

// 保存决定到本地存储
function saveDecision(decision) {
  let history = JSON.parse(localStorage.getItem('decisionHistory') || '[]');
  decision.id = Date.now();
  decision.date = new Date().toISOString();
  history.unshift(decision);
  localStorage.setItem('decisionHistory', JSON.stringify(history));
}

// 获取决定历史
function getDecisionHistory() {
  return JSON.parse(localStorage.getItem('decisionHistory') || '[]');
}

// 删除决定
function deleteDecision(id) {
  let history = getDecisionHistory();
  history = history.filter(item => item.id !== id);
  localStorage.setItem('decisionHistory', JSON.stringify(history));
} 