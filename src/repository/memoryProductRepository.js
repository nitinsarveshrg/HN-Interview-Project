import { randomUUID } from 'crypto';

class InMemoryProductRepository {
  constructor() {
    this.storage = new Map();
  }

  async list() {
    return Array.from(this.storage.values());
  }

  async getById(id) {
    return this.storage.get(id) ?? null;
  }

  async create(product) {
    const id = randomUUID();
    const created = { id, ...product };
    this.storage.set(id, created);
    return created;
  }

  async update(id, product) {
    const existing = this.storage.get(id);
    if (!existing) return null;
    const updated = { ...existing, ...product, id };
    this.storage.set(id, updated);
    return updated;
  }

  async delete(id) {
    return this.storage.delete(id);
  }

  async search(query) {
    const q = query.toLowerCase();
    return Array.from(this.storage.values()).filter(
      (p) => p.name.toLowerCase().includes(q) || p.category.toLowerCase().includes(q)
    );
  }
}

export const productRepository = new InMemoryProductRepository();


