import { productRepository } from '../repository/memoryProductRepository.js';

export const listProducts = () => productRepository.list();
export const getProduct = (id) => productRepository.getById(id);
export const createProduct = (data) => productRepository.create(data);
export const updateProduct = (id, data) => productRepository.update(id, data);
export const deleteProduct = (id) => productRepository.delete(id);
export const searchProducts = (query) => productRepository.search(query);


