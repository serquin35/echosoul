const chatDemo = document.getElementById('chat-demo');

const messages = [
  { role: 'companion', text: 'Hola... ¿cómo te sientes hoy realmente?' },
  { role: 'user', text: 'Un poco abrumado con el trabajo, la verdad.' },
  { role: 'companion', text: 'Entiendo. Respira hondo. Estoy aquí para escucharte. ¿Quieres contarme qué es lo que más te pesa ahora?' },
  { role: 'user', text: 'Siento que no llego a todo.' },
  { role: 'companion', text: 'No tienes que poder con todo tú solo. Recuerda que tu valor no depende de tu productividad. ¿Qué tal si nos tomamos un momento para desconectar?' }
];

async function runDemo() {
  if (!chatDemo) return;
  
  for (const msg of messages) {
    await wait(1500);
    appendMessage(msg.role, msg.text);
    chatDemo.scrollTop = chatDemo.scrollHeight;
  }
}

function appendMessage(role, text) {
  const div = document.createElement('div');
  div.className = `chat-msg ${role}`;
  div.innerHTML = `
    <div class="msg-bubble ${role === 'companion' ? 'glass' : 'primary'}">
      ${text}
    </div>
  `;
  chatDemo.appendChild(div);
}

function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Add basic CSS for chat messages dynamically or via style.css
const style = document.createElement('style');
style.textContent = `
  .chat-msg {
    display: flex;
    margin-bottom: 1rem;
    opacity: 0;
    transform: translateY(10px);
    animation: fadeInMsg 0.5s forwards;
  }
  .chat-msg.user { justify-content: flex-end; }
  .msg-bubble {
    padding: 0.8rem 1.2rem;
    border-radius: 18px;
    max-width: 80%;
    font-size: 0.95rem;
  }
  .msg-bubble.primary {
    background: var(--primary-blue);
    color: var(--deep-blue);
    border-bottom-right-radius: 4px;
  }
  .msg-bubble.glass {
    border-bottom-left-radius: 4px;
  }
  @keyframes fadeInMsg {
    to { opacity: 1; transform: translateY(0); }
  }
`;
document.head.appendChild(style);

// Start demo when in view
const observer = new IntersectionObserver((entries) => {
  if (entries[0].isIntersecting) {
    runDemo();
    observer.disconnect();
  }
}, { threshold: 0.5 });

if (chatDemo) {
  observer.observe(chatDemo);
}

// Dynamic Redirection for App Links
document.addEventListener('click', (e) => {
  const target = e.target.closest('a');
  if (target && target.getAttribute('href')?.startsWith('/app/')) {
    // If we are on localhost, redirect to the production URL for testing
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      e.preventDefault();
      const productionUrl = 'https://echosoul.dev';
      window.location.href = productionUrl + target.getAttribute('href');
    }
  }
});

// Intersection Observer for scroll reveal
const revealOptions = {
  threshold: 0.1,
  rootMargin: '0px 0px -50px 0px'
};

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('revealed');
      revealObserver.unobserve(entry.target);
    }
  });
}, revealOptions);

// Observe all sections and cards
document.querySelectorAll('section, .feature-card, .testimonial-card, .faq-card').forEach(el => {
  el.classList.add('reveal-on-scroll');
  revealObserver.observe(el);
});

// Update styles for reveal effect
const revealStyle = document.createElement('style');
revealStyle.textContent = `
  .reveal-on-scroll {
    opacity: 0;
    transform: translateY(30px);
    transition: all 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .reveal-on-scroll.revealed {
    opacity: 1;
    transform: translateY(0);
  }
`;
document.head.appendChild(revealStyle);

// Navbar scroll effect
window.addEventListener('scroll', () => {
  const nav = document.querySelector('.navbar');
  if (window.scrollY > 50) {
    nav.classList.add('scrolled');
  } else {
    nav.classList.remove('scrolled');
  }
});

// Add navbar scrolled style
const navStyle = document.createElement('style');
navStyle.textContent = `
  .navbar.scrolled {
    background: rgba(7, 11, 20, 0.85) !important;
    backdrop-filter: blur(20px) !important;
    padding: 1rem 0 !important;
    box-shadow: 0 10px 30px rgba(0,0,0,0.3);
  }
`;
document.head.appendChild(navStyle);
