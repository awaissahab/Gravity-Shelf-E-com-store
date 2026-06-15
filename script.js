// Matter.js Module Aliases
const Engine = Matter.Engine,
      World = Matter.World,
      Bodies = Matter.Bodies,
      Mouse = Matter.Mouse,
      MouseConstraint = Matter.MouseConstraint,
      Events = Matter.Events;

// Initialize Engine
const engine = Engine.create();
engine.world.gravity.y = 1.2;

// Complete Product Database
const products = [
    { id: 1, name: "Wireless Headphones", price: 89.99, category: "electronics", img: "https://cdn-icons-png.flaticon.com/512/570/570221.png" },
    { id: 2, name: "Smart Watch Pro", price: 199.99, category: "electronics", img: "https://cdn-icons-png.flaticon.com/512/3659/3659898.png" },
    { id: 3, name: "Laptop Stand", price: 45.99, category: "electronics", img: "https://cdn-icons-png.flaticon.com/512/2048/2048766.png" },
    { id: 4, name: "USB-C Hub", price: 34.99, category: "electronics", img: "https://cdn-icons-png.flaticon.com/512/216/216695.png" },
    { id: 5, name: "Mechanical Keyboard", price: 129.99, category: "electronics", img: "https://cdn-icons-png.flaticon.com/512/1563/1563291.png" },
    
    { id: 6, name: "Running Shoes", price: 119.99, category: "fashion", img: "https://cdn-icons-png.flaticon.com/512/2589/2589903.png" },
    { id: 7, name: "Backpack", price: 65.99, category: "fashion", img: "https://cdn-icons-png.flaticon.com/512/3050/3050257.png" },
    { id: 8, name: "Sunglasses", price: 79.99, category: "fashion", img: "https://cdn-icons-png.flaticon.com/512/340/340772.png" },
    { id: 9, name: "Denim Jacket", price: 89.99, category: "fashion", img: "https://cdn-icons-png.flaticon.com/512/8965/8965222.png" },
    { id: 10, name: "Wrist Watch", price: 149.99, category: "fashion", img: "https://cdn-icons-png.flaticon.com/512/2990/2990565.png" },
    
    { id: 11, name: "Coffee Maker", price: 79.99, category: "home", img: "https://cdn-icons-png.flaticon.com/512/924/924514.png" },
    { id: 12, name: "Table Lamp", price: 49.99, category: "home", img: "https://cdn-icons-png.flaticon.com/512/3209/3209863.png" },
    { id: 13, name: "Plant Pot", price: 24.99, category: "home", img: "https://cdn-icons-png.flaticon.com/512/616/616490.png" },
    { id: 14, name: "Wall Clock", price: 39.99, category: "home", img: "https://cdn-icons-png.flaticon.com/512/2921/2921229.png" },
    { id: 15, name: "Cushion Set", price: 34.99, category: "home", img: "https://cdn-icons-png.flaticon.com/512/3081/3081832.png" },
    
    { id: 16, name: "Yoga Mat", price: 29.99, category: "sports", img: "https://cdn-icons-png.flaticon.com/512/2936/2936886.png" },
    { id: 17, name: "Dumbbells", price: 59.99, category: "sports", img: "https://cdn-icons-png.flaticon.com/512/738/738328.png" },
    { id: 18, name: "Basketball", price: 34.99, category: "sports", img: "https://cdn-icons-png.flaticon.com/512/166/166343.png" },
    { id: 19, name: "Tennis Racket", price: 89.99, category: "sports", img: "https://cdn-icons-png.flaticon.com/512/1036/1036663.png" },
    { id: 20, name: "Water Bottle", price: 19.99, category: "sports", img: "https://cdn-icons-png.flaticon.com/512/1163/1163650.png" }
];

// Cart State
let cart = [];
let currentProduct = null;
let currentQuantity = 1;

const shelfContainer = document.getElementById('shelf');
const domToBodyMap = new Map();
const productElements = new Map();

// Create Boundaries
const width = shelfContainer.offsetWidth || window.innerWidth;
const height = shelfContainer.offsetHeight || window.innerHeight;
const wallThickness = 100;

const ground = Bodies.rectangle(width / 2, height + wallThickness/2 - 10, width, wallThickness, { isStatic: true });
const leftWall = Bodies.rectangle(0 - wallThickness/2, height / 2, wallThickness, height * 2, { isStatic: true });
const rightWall = Bodies.rectangle(width + wallThickness/2, height / 2, wallThickness, height * 2, { isStatic: true });

World.add(engine.world, [ground, leftWall, rightWall]);

// Spawn Products Function
function spawnProducts(filter = 'all') {
    // Clear existing
    World.clear(engine.world, false);
    World.add(engine.world, [ground, leftWall, rightWall]);
    shelfContainer.innerHTML = '';
    domToBodyMap.clear();
    productElements.clear();
    
    const filteredProducts = filter === 'all' 
        ? products 
        : products.filter(p => p.category === filter);
    
    filteredProducts.forEach((prod, index) => {
        // Create DOM Element
        const el = document.createElement('div');
        el.className = 'product-item';
        el.innerHTML = `
            <img src="${prod.img}" alt="${prod.name}" draggable="false">
            <div class="product-name">${prod.name}</div>
            <div class="product-price">$${prod.price}</div>
        `;
        el.dataset.id = prod.id;
        el.dataset.category = prod.category;
        shelfContainer.appendChild(el);
        
        // Create Physics Body
        const startX = Math.random() * (width - 200) + 100;
        const startY = -150 - (index * 180);
        
        const body = Bodies.rectangle(startX, startY, 130, 130, {
            restitution: 0.4,
            friction: 0.5,
            frictionAir: 0.01,
            chamfer: { radius: 10 },
            label: `product-${prod.id}`
        });
        
        World.add(engine.world, body);
        domToBodyMap.set(el, body);
        productElements.set(prod.id, el);
    });
}

// Initial spawn
spawnProducts();

// Mouse/Touch Interaction
const mouse = Mouse.create(shelfContainer);
const mouseConstraint = MouseConstraint.create(engine, {
    mouse: mouse,
    constraint: {
        stiffness: 0.2,
        render: { visible: false }
    }
});
World.add(engine.world, mouseConstraint);

mouse.element.removeEventListener("mousewheel", mouse.mousewheel);
mouse.element.removeEventListener("DOMMouseScroll", mouse.mousewheel);

// Sync Physics to DOM
Events.on(engine, 'afterUpdate', () => {
    domToBodyMap.forEach((body, el) => {
        if (el.classList.contains('is-floating')) return;
        
        const { x, y } = body.position;
        const angle = body.angle;
        
        el.style.transform = `translate(${x - 65}px, ${y - 65}px) rotate(${angle}rad)`;
    });
});

Engine.run(engine);

// Filter Functionality
document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        e.currentTarget.classList.add('active');
        
        const filter = e.currentTarget.dataset.filter;
        spawnProducts(filter);
    });
});

// Product Click - Modal
shelfContainer.addEventListener('click', (e) => {
    const el = e.target.closest('.product-item');
    if (!el || el.classList.contains('is-floating')) return;
    
    const prod = products.find(p => p.id == el.dataset.id);
    const body = domToBodyMap.get(el);
    
    body.isStatic = true;
    el.classList.add('is-floating');
    
    const centerX = window.innerWidth / 2;
    const centerY = window.innerHeight / 2;
    
    gsap.to(el, {
        x: centerX - 65,
        y: centerY - 65,
        rotation: 0,
        scale: 1.5,
        duration: 0.6,
        ease: "back.out(1.2)",
        onComplete: () => {
            showProductModal(prod);
        }
    });
    
    currentProduct = { prod, el, body };
});

// Show Product Modal
function showProductModal(prod) {
    document.getElementById('modalImage').src = prod.img;
    document.getElementById('modalCategory').textContent = prod.category.charAt(0).toUpperCase() + prod.category.slice(1);
    document.getElementById('modalTitle').textContent = prod.name;
    document.getElementById('modalPrice').textContent = `$${prod.price}`;
    document.getElementById('productModal').classList.add('active');
    currentQuantity = 1;
    document.getElementById('qtyValue').textContent = currentQuantity;
}

// Close Modal
document.getElementById('closeModal').addEventListener('click', closeModal);
document.getElementById('productModal').addEventListener('click', (e) => {
    if (e.target.id === 'productModal') closeModal();
});

function closeModal() {
    document.getElementById('productModal').classList.remove('active');
    
    if (currentProduct) {
        gsap.to(currentProduct.el, {
            scale: 1,
            duration: 0.4,
            ease: "power2.in",
            onComplete: () => {
                currentProduct.el.classList.remove('is-floating');
                currentProduct.el.style.transform = '';
                currentProduct.body.isStatic = false;
                
                Matter.Body.setPosition(currentProduct.body, {
                    x: currentProduct.body.position.x,
                    y: currentProduct.body.position.y - 50
                });
                
                currentProduct = null;
            }
        });
    }
}

// Quantity Controls
document.getElementById('qtyMinus').addEventListener('click', () => {
    if (currentQuantity > 1) {
        currentQuantity--;
        document.getElementById('qtyValue').textContent = currentQuantity;
    }
});

document.getElementById('qtyPlus').addEventListener('click', () => {
    currentQuantity++;
    document.getElementById('qtyValue').textContent = currentQuantity;
});

// Add to Cart
document.getElementById('addToCartBtn').addEventListener('click', () => {
    if (currentProduct) {
        addToCart(currentProduct.prod, currentQuantity);
        closeModal();
    }
});

// Cart Functions
function addToCart(product, quantity = 1) {
    const existingItem = cart.find(item => item.id === product.id);
    
    if (existingItem) {
        existingItem.quantity += quantity;
    } else {
        cart.push({ ...product, quantity });
    }
    
    updateCart();
    showCartNotification();
}

function removeFromCart(productId) {
    cart = cart.filter(item => item.id !== productId);
    updateCart();
}

function updateCart() {
    const cartCount = document.getElementById('cartCount');
    const cartItems = document.getElementById('cartItems');
    const cartBody = document.getElementById('cartBody');
    const totalPrice = document.getElementById('totalPrice');
    const cartSubtotal = document.getElementById('cartSubtotal');
    
    const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    
    cartCount.textContent = totalItems;
    totalPrice.textContent = `$${total.toFixed(2)}`;
    cartSubtotal.textContent = `$${total.toFixed(2)}`;
    
    // Update cart summary
    cartItems.innerHTML = cart.map(item => `
        <div class="cart-item">
            <img src="${item.img}" alt="${item.name}">
            <div class="cart-item-info">
                <div class="cart-item-name">${item.name}</div>
                <div class="cart-item-price">$${item.price} x ${item.quantity}</div>
            </div>
        </div>
    `).join('');
    
    // Update cart sidebar
    cartBody.innerHTML = cart.map(item => `
        <div class="cart-item">
            <img src="${item.img}" alt="${item.name}">
            <div class="cart-item-info">
                <div class="cart-item-name">${item.name}</div>
                <div class="cart-item-price">$${item.price}</div>
                <div>Qty: ${item.quantity}</div>
            </div>
            <button onclick="removeFromCart(${item.id})" style="background:none;border:none;color:#e74c3c;cursor:pointer;">
                <i class="fas fa-trash"></i>
            </button>
        </div>
    `).join('');
}

function showCartNotification() {
    const cartIcon = document.getElementById('cartIcon');
    gsap.from(cartIcon, { scale: 1.5, duration: 0.3, ease: "back.out(2)" });
}

// Cart Sidebar Toggle
document.getElementById('cartIcon').addEventListener('click', () => {
    document.getElementById('cartSidebar').classList.add('active');
});

document.getElementById('closeCart').addEventListener('click', () => {
    document.getElementById('cartSidebar').classList.remove('active');
});

document.getElementById('continueShopping').addEventListener('click', () => {
    document.getElementById('cartSidebar').classList.remove('active');
});

// Search Functionality
document.getElementById('searchInput').addEventListener('input', (e) => {
    const searchTerm = e.target.value.toLowerCase();
    const filtered = products.filter(p => 
        p.name.toLowerCase().includes(searchTerm) || 
        p.category.toLowerCase().includes(searchTerm)
    );
    
    // Visual feedback for search
    document.querySelectorAll('.product-item').forEach(el => {
        const prod = products.find(p => p.id == el.dataset.id);
        if (filtered.find(f => f.id === prod.id)) {
            el.style.opacity = '1';
            el.style.transform += ' scale(1)';
        } else {
            el.style.opacity = '0.3';
        }
    });
});

// Checkout
document.getElementById('checkoutBtn').addEventListener('click', () => {
    if (cart.length === 0) {
        alert('Your cart is empty!');
        return;
    }
    alert(`Proceeding to checkout! Total: $${cart.reduce((sum, item) => sum + (item.price * item.quantity), 0).toFixed(2)}`);
});

// Window Resize
window.addEventListener('resize', () => {
    const newWidth = shelfContainer.offsetWidth;
    const newHeight = shelfContainer.offsetHeight;
    Matter.Body.setPosition(ground, { x: newWidth / 2, y: newHeight + 40 });
    Matter.Body.setPosition(rightWall, { x: newWidth + 50, y: newHeight / 2 });
});